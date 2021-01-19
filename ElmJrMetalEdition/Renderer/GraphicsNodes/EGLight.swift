//
//  EGLight.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2021-01-13.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import Foundation

class EGLight {
    static func directional(color: simd_float3, position: simd_float3, intensity: Float, specularColor: simd_float3) -> Light {
        var light = Light()
        light.position = position
        light.color = color
        light.intensity = intensity
        light.type = Directional
        light.specularColor = specularColor
        return light
    }

    static func ambient(color: simd_float3, intensity: Float) -> Light {
        var light = Light()
        light.color = color
        light.intensity = intensity
        light.type = Ambient
        return light
    }
}