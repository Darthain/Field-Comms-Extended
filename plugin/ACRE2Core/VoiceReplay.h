#pragma once
// Field Comms Extended: voice replay.
// A short, in-memory record of what opted-in players last said, so the game can play one of their clips back from a
// position in the world (SCP Hazards and Anomalies' SCP-939 uses it; any mod can, through the RPCs in fce_voiceReplay.h).
//
// Privacy, enforced here rather than left to the scripts:
//  - nothing is kept unless the feature is switched on (server setting) AND that player has opted in (their own setting);
//  - clips live only in this process's memory: never written to disk, never sent anywhere;
//  - a fixed small amount per player (MAX_CLIPS clips of up to MAX_CLIP_SECONDS), oldest overwritten;
//  - a player's clips are dropped the moment they leave the consent list, and everything is dropped on mission end,
//    pipe disconnect and plugin shutdown.
#include <chrono>
#include <cstdint>
#include <deque>
#include <map>
#include <mutex>
#include <set>
#include <vector>

class CVoiceReplay {
public:
    static CVoiceReplay *getInstance();

    // TeamSpeak audio thread: a block of decoded voice from one speaker (before any ACRE effect)
    void capture(const uint32_t id, const short *const samples, const int sampleCount, const int channels);

    // Game: switch the feature on or off, and who has opted in (TeamSpeak client IDs). Anyone not listed is forgotten.
    void setConsent(const bool enabled, const std::set<uint32_t> &ids);

    // Forget everything
    void clear();

    // A copy of one of this speaker's clips, pitch-shifted by resampling and faded at the ends. False if there's none.
    bool getClip(const uint32_t id, const bool latest, const float pitch, std::vector<short> &out);

    static constexpr int RATE = 48000;              // TeamSpeak's voice playback rate
    static constexpr int MAX_CLIP_SECONDS = 4;
    static constexpr int MAX_CLIP = RATE * MAX_CLIP_SECONDS;
    static constexpr int MIN_CLIP = RATE * 6 / 10;  // under 0.6 s isn't worth keeping
    static constexpr int MAX_CLIPS = 3;             // per speaker
    static constexpr int MAX_SPEAKERS = 32;         // about 1.1 MB each at most
    static constexpr int GAP_MS = 350;              // a pause this long ends an utterance

private:
    CVoiceReplay() = default;
    struct Speaker {
        std::deque<std::vector<short>> clips;
        std::vector<short> current;
        std::chrono::steady_clock::time_point last;
    };
    static void finishCurrent(Speaker &speaker);

    std::mutex m_Lock;
    bool m_Enabled = false;
    std::set<uint32_t> m_Consent;
    std::map<uint32_t, Speaker> m_Speakers;
    uint32_t m_Rng = 0x9E3779B9u;
};
