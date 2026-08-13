public let stableAeroSpaceAppId: String = "nagasrinath.deewm"
#if DEBUG
    public let aeroSpaceAppId: String = "nagasrinath.deewm.debug"
    public let aeroSpaceAppName: String = "DeeWM-Debug"
#else
    public let aeroSpaceAppId: String = stableAeroSpaceAppId
    public let aeroSpaceAppName: String = "DeeWM"
#endif
