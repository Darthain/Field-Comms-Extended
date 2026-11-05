// Field Comms Extended: voice replay (see VoiceReplay.h)
#include "VoiceReplay.h"

#include <algorithm>
#include <cmath>

CVoiceReplay *CVoiceReplay::getInstance() {
    static CVoiceReplay instance;
    return &instance;
}

void CVoiceReplay::finishCurrent(Speaker &speaker) {
    if (static_cast<int>(speaker.current.size()) >= MIN_CLIP) {
        speaker.clips.push_back(std::move(speaker.current));
        while (static_cast<int>(speaker.clips.size()) > MAX_CLIPS) {
            speaker.clips.pop_front();
        }
    }
    speaker.current = std::vector<short>();
}

void CVoiceReplay::capture(const uint32_t id, const short *const samples, const int sampleCount, const int channels) {
    if (samples == nullptr || sampleCount <= 0 || channels <= 0) {
        return;
    }
    std::lock_guard<std::mutex> guard(m_Lock);
    if (!m_Enabled || m_Consent.find(id) == m_Consent.end()) {
        return;
    }
    auto it = m_Speakers.find(id);
    if (it == m_Speakers.end()) {
        if (static_cast<int>(m_Speakers.size()) >= MAX_SPEAKERS) {
            return;
        }
        it = m_Speakers.emplace(id, Speaker()).first;
    }
    Speaker &speaker = it->second;
    const auto now = std::chrono::steady_clock::now();
    if (!speaker.current.empty() &&
        std::chrono::duration_cast<std::chrono::milliseconds>(now - speaker.last).count() > GAP_MS) {
        finishCurrent(speaker);
    }
    speaker.last = now;
    const int room = MAX_CLIP - static_cast<int>(speaker.current.size());
    const int take = std::min(room, sampleCount);
    if (take <= 0) {
        return;   // this utterance already fills a clip: the rest of it isn't kept
    }
    if (speaker.current.capacity() == 0) {
        speaker.current.reserve(MAX_CLIP);
    }
    for (int i = 0; i < take; ++i) {
        speaker.current.push_back(samples[i * channels]);   // first channel only (voice playback is mono)
    }
}

void CVoiceReplay::setConsent(const bool enabled, const std::set<uint32_t> &ids) {
    std::lock_guard<std::mutex> guard(m_Lock);
    m_Enabled = enabled;
    m_Consent = enabled ? ids : std::set<uint32_t>();
    for (auto it = m_Speakers.begin(); it != m_Speakers.end();) {
        if (m_Consent.find(it->first) == m_Consent.end()) {
            it = m_Speakers.erase(it);
        } else {
            ++it;
        }
    }
}

void CVoiceReplay::clear() {
    std::lock_guard<std::mutex> guard(m_Lock);
    m_Speakers.clear();
}

bool CVoiceReplay::getClip(const uint32_t id, const bool latest, const float pitch, std::vector<short> &out) {
    std::vector<short> clip;
    {
        std::lock_guard<std::mutex> guard(m_Lock);
        if (!m_Enabled || m_Consent.find(id) == m_Consent.end()) {
            return false;
        }
        auto it = m_Speakers.find(id);
        if (it == m_Speakers.end()) {
            return false;
        }
        Speaker &speaker = it->second;
        if (!speaker.current.empty() &&
            std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now() - speaker.last).count() > GAP_MS) {
            finishCurrent(speaker);
        }
        if (speaker.clips.empty()) {
            return false;
        }
        size_t index = speaker.clips.size() - 1;
        if (!latest) {
            m_Rng = m_Rng * 1664525u + 1013904223u;
            index = (m_Rng >> 8) % speaker.clips.size();
        }
        clip = speaker.clips[index];   // a copy: playback never touches the store
    }
    const double step = std::max(0.5, std::min(2.0, static_cast<double>(pitch)));
    const size_t outCount = static_cast<size_t>(static_cast<double>(clip.size()) / step);
    out.assign(outCount, 0);
    for (size_t i = 0; i < outCount; ++i) {
        const double src = static_cast<double>(i) * step;
        const size_t a = static_cast<size_t>(src);
        const size_t b = std::min(a + 1, clip.size() - 1);
        const double t = src - static_cast<double>(a);
        out[i] = static_cast<short>(clip[a] * (1.0 - t) + clip[b] * t);
    }
    // short fades so it doesn't click in and out
    const size_t fade = std::min(out.size() / 4, static_cast<size_t>(RATE / 100));
    for (size_t i = 0; i < fade; ++i) {
        const double g = static_cast<double>(i) / static_cast<double>(fade);
        out[i] = static_cast<short>(out[i] * g);
        out[out.size() - 1 - i] = static_cast<short>(out[out.size() - 1 - i] * g);
    }
    return !out.empty();
}
