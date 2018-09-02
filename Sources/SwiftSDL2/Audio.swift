//
//  Audio.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2018/8/12.
//

import CSDL2

// MARK: - AudioFormat

/// Audio format flags.
///
/// These are what the 16 bits in SDL_AudioFormat currently mean...
/// (Unspecified bits are always zero).
///
///     ```
///     ++-----------------------sample is signed if set
///     ||
///     ||       ++-----------sample is bigendian if set
///     ||       ||
///     ||       ||          ++---sample is float if set
///     ||       ||          ||
///     ||       ||          || +---sample bit size---+
///     ||       ||          || |                     |
///     15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
///     ```
public typealias AudioFormat = SDL_AudioFormat

extension AudioFormat {
    // MARK: - 8-bit support

    // signed 8-bit samples
    public static let s8 = UInt16(AUDIO_S8)
    // unsigned 8-bit samples
    public static let u8 = UInt16(AUDIO_U8)

    // MARK: - 16-bit support

    // signed 16-bit samples in little-endian byte order
    public static let s16lsb = UInt16(AUDIO_S16LSB)
    // signed 16-bit samples in big-endian byte order
    public static let s16msb = UInt16(AUDIO_S16MSB)
    // signed 16-bit samples in native byte order
    public static let s16sys = UInt16(AUDIO_S16SYS)
    // AUDIO_S16LSB
    public static let s16 = UInt16(AUDIO_S16)
    // unsigned 16-bit samples in little-endian byte order
    public static let u16lsb = UInt16(AUDIO_U16LSB)
    // unsigned 16-bit samples in big-endian byte order
    public static let u16msb = UInt16(AUDIO_U16MSB)
    // unsigned 16-bit samples in native byte order
    public static let u16sys = UInt16(AUDIO_U16SYS)
    // AUDIO_U16LSB
    public static let u16 = UInt16(AUDIO_U16)

    // MARK: - 32-bit support

    // 32-bit integer samples in little-endian byte order
    public static let s32lsb = UInt16(AUDIO_S32LSB)
    // 32-bit integer samples in big-endian byte order
    public static let s32msb = UInt16(AUDIO_S32MSB)
    // 32-bit integer samples in native byte order
    public static let s32sys = UInt16(AUDIO_S32SYS)
    // AUDIO_S32LSB
    public static let s32 = UInt16(AUDIO_S32)

    // MARK: - float support

    // 32-bit floating point samples in little-endian byte order
    public static let f32lsb = UInt16(AUDIO_F32LSB)
    // 32-bit floating point samples in big-endian byte order
    public static let f32msb = UInt16(AUDIO_F32MSB)
    // 32-bit floating point samples in native byte order
    public static let f32sys = UInt16(AUDIO_F32SYS)
    // AUDIO_F32LSB
    public static let f32 = UInt16(AUDIO_F32)
}

// MARK: - AudioStatus

/// Audio state
public typealias AudioStatus = SDL_AudioStatus

extension AudioStatus {
    // audio device is stopped
    public static let stopped = SDL_AUDIO_STOPPED
    // audio device is playing
    public static let playing = SDL_AUDIO_PLAYING
    // audio device is paused
    public static let paused = SDL_AUDIO_PAUSED
}

// MARK: - AudioSpec

/// The calculated values in this structure are calculated by SDL_OpenAudio().
///
/// For multi-channel audio, the default SDL channel mapping is:
///   - 2:  FL FR                       (stereo)
///   - 3:  FL FR LFE                   (2.1 surround)
///   - 4:  FL FR BL BR                 (quad)
///   - 5:  FL FR FC BL BR              (quad + center)
///   - 6:  FL FR FC LFE SL SR          (5.1 surround - last two can also be BL BR)
///   - 7:  FL FR FC LFE BC SL SR       (6.1 surround)
///   - 8:  FL FR FC LFE BL BR SL SR    (7.1 surround)
public typealias AudioSpec = SDL_AudioSpec
public typealias AudioCallback = SDL_AudioCallback

public final class AudioDevice {
    /// Allow change flags
    ///
    /// Which audio format changes are allowed when opening a device.
    public struct AllowedChangeFlags: OptionSet {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        public static let frequency = AllowedChangeFlags(rawValue: SDL_AUDIO_ALLOW_FREQUENCY_CHANGE)
        public static let format = AllowedChangeFlags(rawValue: SDL_AUDIO_ALLOW_FORMAT_CHANGE)
        public static let channels = AllowedChangeFlags(rawValue: SDL_AUDIO_ALLOW_CHANNELS_CHANGE)
        public static let any = [.frequency, .format, .channels] as AllowedChangeFlags
    }

    let deviceId: SDL_AudioDeviceID

    /// the desired output format
    public let desiredSpec: AudioSpec
    /// the obtained output format
    public let obtainedSpec: AudioSpec

    /// Create and open a specific audio device. Passing in a device name of nil requests
    /// the most reasonable default (and is equivalent to calling SDL_OpenAudio()).
    ///
    /// - Parameters:
    ///   - device: device name
    ////  - isCapture: non-zero to specify a device should be opened for recording, not playback
    ///   - spec: the desired output format
    ///   - flags: 0, or one or more flags OR'd together
    /// - Throws: SDLError
    public init(
        device: String?,
        isCapture: Bool,
        spec: AudioSpec,
        flags: AudioDevice.AllowedChangeFlags
    ) throws {
        var desiredSpec = spec
        var obtainedSpec = AudioSpec()
        let deviceId = SDL_OpenAudioDevice(device, isCapture ? 1 : 0, &desiredSpec, &obtainedSpec, flags.rawValue)
        if deviceId == 0 { throw SDLError(code: Int32(deviceId)) }
        self.deviceId = deviceId
        self.desiredSpec = desiredSpec
        self.obtainedSpec = obtainedSpec
    }

    /// The current audio state of an audio device.
    public var status: AudioStatus {
        return SDL_GetAudioDeviceStatus(deviceId)
    }

    /// Pause audio playback on a specified device.
    public func pause() {
        SDL_PauseAudioDevice(deviceId, 1)
    }

    /// Resume audio playback on a specified device.
    public func resume() {
        SDL_PauseAudioDevice(deviceId, 0)
    }

    /// Lock out the audio callback function for a specified device.
    public func lock() {
        SDL_LockAudioDevice(deviceId)
    }

    /// Unlock the audio callback function for a specified device.
    public func unlock() {
        SDL_UnlockAudioDevice(deviceId)
    }

    /// Get the number of available devices exposed by the current driver.
    /// Only valid after a successfully initializing the audio subsystem.
    ///
    /// In many common cases, when this function returns a value <= 0, it can still
    /// successfully open the default device (NULL for first argument of
    /// SDL_OpenAudioDevice()).
    ///
    /// - Parameter isCapture: zero to request playback devices, non-zero to request recording devices
    /// - Returns: Returns -1 if an explicit list of devices can't be determined; this is
    ///   not an error. For example, if SDL is set up to talk to a remote audio
    ///   server, it can't list every one available on the Internet, but it will
    ///   still allow a specific host to be specified to SDL_OpenAudioDevice().
    public static func deviceCount(isCapture: Bool) -> Int {
        return Int(SDL_GetNumAudioDevices(isCapture ? 1 : 0))
    }

    /// Get the human-readable name of a specific audio device.
    ///
    /// - Parameters:
    ///   - index: the index of the audio device; the value ranges from 0 to deviceCount - 1
    ///   - isCapture: true to specify a device that has recording capability
    /// - Returns: Returns the name of the audio device at the requested index, or nil on error.
    public static func deviceName(index: Int, isCapture: Bool) -> String? {
        assert(index < deviceCount(isCapture: isCapture), "Must be a value between 0 and (number of audio devices-1).")
        return String(cString: SDL_GetAudioDeviceName(Int32(index), isCapture ? 1 : 0))
    }

    /// Gget the number of built-in audio drivers.
    ///
    /// - Returns: Returns the number of built-in audio drivers.
    public static func driverCount(isCapture: Bool) -> Int {
        return Int(SDL_GetNumAudioDrivers())
    }

    /// Get the human-readable name of a specific audio driver.
    ///
    /// - Parameters:
    ///   - index: the index of the audio driver; the value ranges from 0 to driverCount - 1
    /// - Returns: the name of the audio driver at the requested index, or nil if an invalid index was specified.
    public static func driverName(index: Int) -> String? {
        return String(cString: SDL_GetAudioDriver(Int32(index)))
    }

    deinit {
        SDL_CloseAudioDevice(deviceId)
    }
}

public let MIX_MAXVOLUME = Int(SDL_MIX_MAXVOLUME)

/// Mix audio data in a specified format.
///
/// - Parameters:
///   - dst: the destination for the mixed audio
///   - src: the source audio buffer to be mixed
///   - format: the desired audio format
///   - len: the length of the audio buffer in bytes
///   - volume: ranges from 0 - 128, and should be set to `MIX_MAXVOLUME` for full audio volume
public func mixAudio(
    dst: UnsafeMutablePointer<UInt8>,
    src: UnsafePointer<UInt8>,
    format: AudioFormat,
    len: Int,
    volume: Int = MIX_MAXVOLUME
) {
    SDL_MixAudioFormat(dst, src, format, UInt32(len), Int32(volume))
}
