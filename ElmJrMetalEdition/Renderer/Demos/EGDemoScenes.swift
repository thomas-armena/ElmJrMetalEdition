//
//  EGDemoScenes.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-12-01.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class EGDemoScenes {
    static func spinningFan() -> EGScene {
        let scene = EGScene()
        scene.sceneProps?.viewMatrix = EGMatrixBuilder.createTranslationMatrix(x: 0, y: 0, z: -100)

        let numBlades = 8
        let rotationChange = (2 * Float.pi) / Float(numBlades)

        for i in 0 ..< numBlades {
            let rotationBuffer = rotationChange * Float(i)
            let blade = EGCurvedPolygon(
                p0: EGPoint2D(x: 0, y: 0),
                p1: EGPoint2D(x: 10, y: 10),
                p2: EGPoint2D(x: 20, y: 10),
                p3: EGPoint2D(x: 30, y: 0)
            )

            blade.transform.zRotationMatrix.setZRotation(
                angle: EGBinaryOp(
                    type: .add,
                    leftChild: EGConstant(rotationBuffer),
                    rightChild: EGBinaryOp(
                        type: .mul,
                        leftChild: EGConstant(0.5),
                        rightChild: EGTime()
                    )
                )
            )

            blade.p3.xEquation = EGBinaryOp(
                type: .add,
                leftChild: EGConstant(30),
                rightChild: EGBinaryOp(
                    type: .mul, leftChild: EGConstant(20),
                    rightChild: EGUnaryOp(
                        type: i % 2 == 0 ? .cos : .sin,
                        child: EGTime()
                    )
                )
            )

            blade.transform.translationMatrix.xEquation = EGBinaryOp(
                type: .mul,
                leftChild: EGConstant(30),
                rightChild: EGUnaryOp(
                    type: .cos,
                    child: EGTime()
                )
            )
            blade.color.setColor(
                r: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .sin, child: EGTime())),
                g: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .cos, child: EGTime())),
                b: EGConstant(1),
                a: EGConstant(1)
            )
            scene.add(blade)
        }

        let circle = EGRegularPolygon(30)
        circle.transform.scaleMatrix.setScale(x: 5, y: 5, z: 1)
        circle.transform.translationMatrix.xEquation = EGBinaryOp(
            type: .mul,
            leftChild: EGConstant(30),
            rightChild: EGUnaryOp(
                type: .cos,
                child: EGTime()
            )
        )
        circle.color.setColor(
            r: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .sin, child: EGTime())),
            g: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .cos, child: EGTime())),
            b: EGConstant(1),
            a: EGConstant(1)
        )
        scene.add(circle)

        return scene
    }

    static func fractalTree() -> EGScene {
        let scene = EGScene()
        scene.sceneProps?.viewMatrix = EGMatrixBuilder.createTranslationMatrix(x: 0, y: 0, z: -150)

        func fratcalTreeHelper(currentDepth: Float, rotation: Float, currentPos: simd_float3, length: Float) {
            if length < 1 { return }

            let theta = 30 * Float.pi / 180
            let nextPoint = simd_float3(currentPos.x + (length * cos(rotation)), currentPos.y + (length * sin(rotation)), 0)
            let line = EGLine2D(
                p0: currentPos,
                p1: nextPoint,
                size: max(0.2, 1 - (currentDepth * 0.45))
            )
            fratcalTreeHelper(
                currentDepth: currentDepth + 1,
                rotation: rotation + theta,
                currentPos: nextPoint,
                length: length - 1.5
            )
            fratcalTreeHelper(
                currentDepth: currentDepth + 1,
                rotation: rotation - theta,
                currentPos: nextPoint,
                length: length - 1.5
            )
            if currentDepth > 8 {
                line.color.rEquation = EGUnaryOp(type: .abs, child: EGUnaryOp(type: .sin, child: EGTime()))
                line.color.gEquation = EGUnaryOp(type: .abs, child: EGUnaryOp(type: .cos, child: EGTime()))
            }
            scene.add(line)
        }

        fratcalTreeHelper(currentDepth: 0, rotation: Float.pi / 2, currentPos: simd_float3(0, -60, 0), length: 20)

        return scene
    }
}