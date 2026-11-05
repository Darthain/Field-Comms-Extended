#pragma once
// Field Comms Extended: voice replay RPCs (game -> plugin). See VoiceReplay.h for what's kept and the privacy rules.
//
//   fce_setVoiceReplay:   enabled (0/1), opted-in TeamSpeak IDs as one parameter "12;40;7"
//   fce_playVoiceReplay:  TeamSpeak ID, position x, y, z (ASL), direction x, y, z, volume 0..1, pitch, latest (0/1), tag
//                         -> replies fce_handleVoiceReplay: tag, 1 if it played / 0 if there was nothing to play
//   fce_clearVoiceReplay: (none) forget every clip
#include "compat.h"
#include "Types.h"
#include "Macros.h"
#include "Log.h"
#include "IRpcFunction.h"
#include "IServer.h"
#include "Engine.h"
#include "TextMessage.h"
#include "SoundEngine.h"
#include "SoundMixer.h"
#include "SoundMonoChannel.h"
#include "VoiceReplay.h"

#include <cstdlib>
#include <set>
#include <string>
#include <vector>

RPC_FUNCTION(fce_setVoiceReplay) {
    const bool enabled = vMessage->getParameterAsInt(0) == 1;
    std::set<uint32_t> ids;
    if (vMessage->getParameterCount() > 1 && vMessage->getParameter(1) != nullptr) {
        const std::string list = std::string(reinterpret_cast<const char *>(vMessage->getParameter(1)));
        size_t start = 0;
        while (start <= list.size()) {
            const size_t end = list.find(';', start);
            const std::string part = list.substr(start, end == std::string::npos ? std::string::npos : end - start);
            if (!part.empty()) {
                ids.insert(static_cast<uint32_t>(std::strtoul(part.c_str(), nullptr, 10)));
            }
            if (end == std::string::npos) {
                break;
            }
            start = end + 1;
        }
    }
    CVoiceReplay::getInstance()->setConsent(enabled, ids);
    return acre::Result::ok;
}
public:
    inline void setName(const char *const value) final { m_Name = value; }
    inline const char* getName() const final { return m_Name; }

protected:
    const char* m_Name;
};

RPC_FUNCTION(fce_playVoiceReplay) {
    const uint32_t id = static_cast<uint32_t>(vMessage->getParameterAsInt(0));
    // ACRE's own sound calls swap y and z the same way (playLoadedSound)
    const acre::vec3_fp32_t position(vMessage->getParameterAsFloat(1), vMessage->getParameterAsFloat(3), vMessage->getParameterAsFloat(2));
    const acre::vec3_fp32_t direction(vMessage->getParameterAsFloat(4), vMessage->getParameterAsFloat(6), vMessage->getParameterAsFloat(5));
    const float32_t volume = vMessage->getParameterAsFloat(7);
    const float32_t pitch = vMessage->getParameterAsFloat(8);
    const bool latest = vMessage->getParameterAsInt(9) == 1;
    const std::string tag = vMessage->getParameterCount() > 10 && vMessage->getParameter(10) != nullptr
        ? std::string(reinterpret_cast<const char *>(vMessage->getParameter(10))) : std::string("");

    std::vector<short> clip;
    bool played = false;
    if (CVoiceReplay::getInstance()->getClip(id, latest, pitch, clip)) {
        CSoundChannelMono *channel = nullptr;
        CSoundMixer *mixer = CEngine::getInstance()->getSoundEngine()->getSoundMixer();
        mixer->lock();
        if (mixer->acquireChannel(&channel, static_cast<int>(clip.size()), true) && channel != nullptr) {
            channel->setEffectInsert(0, "acre_volume");
            channel->getEffectInsert(0)->setParam("volume", volume);
            channel->setMixdownEffectInsert(0, "acre_positional");
            channel->getMixdownEffectInsert(0)->setParam("speakerPosX", position.x);
            channel->getMixdownEffectInsert(0)->setParam("speakerPosY", position.y);
            channel->getMixdownEffectInsert(0)->setParam("speakerPosZ", position.z);
            channel->getMixdownEffectInsert(0)->setParam("headVectorX", direction.x);
            channel->getMixdownEffectInsert(0)->setParam("headVectorY", direction.y);
            channel->getMixdownEffectInsert(0)->setParam("headVectorZ", direction.z);
            channel->getMixdownEffectInsert(0)->setParam("isWorld", 0x00000000);
            channel->In(clip.data(), static_cast<int>(clip.size()), 1);
            played = true;
        }
        mixer->unlock();
    }
    vServer->sendMessage(CTextMessage::formatNewMessage("fce_handleVoiceReplay", "%s,%d,", tag.c_str(), played ? 1 : 0));
    return acre::Result::ok;
}
public:
    inline void setName(const char *const value) final { m_Name = value; }
    inline const char* getName() const final { return m_Name; }

protected:
    const char* m_Name;
};

RPC_FUNCTION(fce_clearVoiceReplay) {
    CVoiceReplay::getInstance()->clear();
    return acre::Result::ok;
}
public:
    inline void setName(const char *const value) final { m_Name = value; }
    inline const char* getName() const final { return m_Name; }

protected:
    const char* m_Name;
};
