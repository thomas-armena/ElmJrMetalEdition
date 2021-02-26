//
//  TranspilerRefactor.swift
//  ElmJrMetalEdition
//
//  Created by Saad Khan on 2021-02-09.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import Foundation

func transpile(node: EINode) -> EGScene {
    var node = node
    if let function = node as? EIAST.Function{
        node = function.body
    }
    let scene = EGScene()
    sceneTranspiler(node: node, scene: scene)
    let shapes = shapesTranspiler(node: node)
    for shape in shapes{
        scene.add(shape)
    }
    return scene
}

func sceneTranspiler(node: EINode, scene: EGScene){

    let inst = node as! EIAST.ConstructorInstance
    for param in inst.parameters{
        switch param{
        case let camera as EIAST.ConstructorInstance:
            let typeOfCamera = camera.constructorName
            if typeOfCamera == "ArcballCamera"{
                arcballCameraHelper(scene: scene, node: camera)
            }
            else if typeOfCamera == "Camera"{
                cameraHelper(scene: scene, node: camera)
            }
            else {
                print("Not sure what this RGB Parameter is for so this is a placeholder")
            }
        case let list as EIAST.List:
            lightingHelper(scene: scene, lightingList: list)
        default:
        break
        }
    }
}

func cameraHelper(scene: EGScene, node: EINode) {
    let camera = EGCamera()
    let node = node as! EIAST.ConstructorInstance

    let transform = node.parameters[0] as! EIAST.ConstructorInstance
    switch transform.constructorName{
    case "Translate":
        let cameraTransform = unwrapTransform(transform: transform, isRotation: false)
        camera.transform.translate.set(x: cameraTransform[0], y: cameraTransform[1], z: cameraTransform[2])
    case "Scale":
        let cameraTransform = unwrapTransform(transform: transform, isRotation: false)
        camera.transform.scale.set(x: cameraTransform[0], y: cameraTransform[1], z: cameraTransform[2])
    case "Rotate3D":
        let cameraTransform = unwrapTransform(transform: transform, isRotation: true)
        camera.transform.rotate.set(x: cameraTransform[0], y: cameraTransform[1], z: cameraTransform[2])
    default:
        break
    }
    scene.camera = camera
}

func arcballCameraHelper(scene: EGScene, node: EINode) {
    var distance = Float()
    var target = simd_float3()
    let camera = node as! EIAST.ConstructorInstance
    for param in camera.parameters{
        switch param{
        case let int as EIAST.Integer:
            distance = Float(unwrapInt(wrappedInt: int))
            //have to do this because arcball expects a float, but elm defines the paramater as an int
        case let tuple as EIAST.Tuple:
            target = unwrapTuple(wrappedTuple: tuple)
        default:
            break
        }
    }
    
    //TODO: implement scenecolor, and rotation optionals

    let arcballCamera = EGArcballCamera(distance: distance, target: target)
    scene.camera = arcballCamera
    print("Set Arcball Camera")
}

func lightingHelper(scene: EGScene, lightingList: EINode){
    let list = lightingList as! EIAST.List
    for item in list.items{
        let inst = item as! EIAST.ConstructorInstance
        switch inst.constructorName{
        case "DirectionalLight":
            directionalLightHelper(scene: scene, node: inst)
        case "AmbientLight":
            ambientLightHelper(scene: scene, node: inst)
        default:
            break
        }
    }
}

func directionalLightHelper(scene: EGScene, node: EINode){
    let inst = node as! EIAST.ConstructorInstance
    let color = rgbHelper(node: inst.parameters[0])
    let position = unwrapTuple(wrappedTuple: inst.parameters[1])
    let specularColor = rgbHelper(node: inst.parameters[2])
    scene.lights.append(EGLight.directional(color: color, position: position, intensity: 0, specularColor: specularColor))
    print("Set Directional Light with colour:",color,", position:", position, "specularColor:", specularColor)
}

func ambientLightHelper(scene: EGScene, node: EINode){
    let inst = node as! EIAST.ConstructorInstance
    //TODO: WHY IS RGB PASSING IN INTS
    let color = rgbHelper(node: inst.parameters[0])
    let intensity = unwrapFloat(wrappedFloat: inst.parameters[1])
    scene.lights.append(EGLight.ambient(color: color, intensity:intensity))
    print("Set Ambient Light with color:", color,", intensity:", intensity)
}

func rgbHelper(node: EINode) -> simd_float3 {
    var values = [Float]()
    var unwrappedRGB = simd_float3()

    let rgb = node as! EIAST.ConstructorInstance
    for value in rgb.parameters{
        values.append(unwrapFloat(wrappedFloat: value))
    }

    unwrappedRGB.x = values[0]
    unwrappedRGB.y = values[1]
    unwrappedRGB.z = values[2]

    return unwrappedRGB
}

func shapesTranspiler(node: EINode) -> [EGGraphicsNode] {
    var shapes = [EGGraphicsNode]()
    let inst = node as! EIAST.ConstructorInstance
    if let function = inst.parameters[3] as? EIAST.Function{
        let list = function.body as! EIAST.List
        for shape in list.items{
            shapes.append(addShape(node: shape))
        }
    }
    else{
        let list = inst.parameters[3] as! EIAST.List
        for shape in list.items{
            shapes.append(addShape(node: shape))
        }
    }
    return shapes
}

func addShape(node: EINode) -> EGGraphicsNode {
    print("Dealing with shape: ", node)
    switch node{
    case let inst as EIAST.ConstructorInstance:
        switch inst.constructorName{
        case "Inked":
            return inkedHelper(node: inst)
        case "ApTransform":
            return apTransformHelper(node: inst)
        case "Group":
            //TODO: grouping
            break
        default:
            break
        }
    default:
        break
    }
    return EGGraphicsNode()
}

func apTransformHelper(node: EINode) -> EGGraphicsNode {
    var shape = EGGraphicsNode()
    var transform = [EGMathNode]()
    var transformType = String()
    let inst = node as! EIAST.ConstructorInstance
    for paramater in inst.parameters{
        let param = paramater as! EIAST.ConstructorInstance
        switch param.constructorName {
        case "Translate":
            transformType = "Translate"
            transform = unwrapTransform(transform: param, isRotation: false)
        case "Scale":
            transformType = "Scale"
            transform = unwrapTransform(transform: param, isRotation: false)
        case "Rotate3D":
            transformType = "Rotate3D"
            transform = unwrapTransform(transform: param, isRotation: true)
        case "Rotate2D":
            break
        case "Inked":
            shape = inkedHelper(node:param)
        case "ApTransform":
            shape = apTransformHelper(node: param)
        default:
            break
        }
    }
    return applyTransform(shape: shape, transform: transform, transformType: transformType)
}

func unwrapTransform(transform: EINode, isRotation: Bool) -> [EGMathNode] {
    let transform = transform as! EIAST.ConstructorInstance
    let tuple = transform.parameters[0] as! EIAST.Tuple
    
    if isRotation{
        let x = constructTransform(node: tuple.v1, radians: true)
        let y = constructTransform(node: tuple.v2, radians: true)
        let z = constructTransform(node: tuple.v3!, radians: true)
        print("Passing back transform of ", tuple.v1, tuple.v2, tuple.v3!)
        return [x,y,z]
    }

    let x = constructTransform(node: tuple.v1)
    let y = constructTransform(node: tuple.v2)
    let z = constructTransform(node: tuple.v3!)
    print("Passing back transform of ", tuple.v1, tuple.v2, tuple.v3!)
    return [x,y,z]
}

func constructTransform(node: EINode, radians: Bool = false) -> EGMathNode{
    
    switch node{
    case let variable as EIAST.Variable:
        switch variable.name{
        case "time":
            return EGTime()
        default:
            break
        }
        
    case let int as EIAST.Integer:
        if radians{
            return EGConstant(Float(unwrapInt(wrappedInt: int)).degreesToRadians)

        }
        return EGConstant(Float(unwrapInt(wrappedInt: int)))
        
    case let float as EIAST.FloatingPoint:
        if radians{
            return EGConstant(unwrapFloat(wrappedFloat: float).degreesToRadians)
        }
        return EGConstant(unwrapFloat(wrappedFloat: float))
        
    case let unOp as EIAST.UnaryOp:
        let unaryOp = EGUnaryOp(
            type: unOptypeConverter(type: unOp.type.rawValue),
            child: constructTransform(node: unOp.operand, radians: radians))
        return unaryOp
        
    case let binOp as EIAST.BinaryOp:
        let binaryOp = EGBinaryOp(
            type: binOptypeConverter(type: binOp.type.rawValue),
            leftChild: constructTransform(node: binOp.leftOperand, radians: radians),
            rightChild: constructTransform(node: binOp.rightOperand, radians: radians)
        )
        return binaryOp
        
    case let inst as EIAST.ConstructorInstance:
        //unOp is stored as binOp need clarification on this
        if let unOp = inst.parameters[0] as? EIAST.BinaryOp{
            let unaryOp = EGUnaryOp(
                type: unOptypeConverter(type: inst.constructorName),
                child: constructTransform(node: unOp, radians: radians)
            )
            return unaryOp
            }
    
    default:
        break
    }
    return EGConstant(1)
}

func binOptypeConverter(type: String) -> EGBinaryOp.BinaryOpType {
    switch type{
    case "+":
        return .add
    case "-":
        return .sub
    case "*":
        return .mul
    case "/":
        return .div
    
    //not sure if cases below are correct
    case "Max":
        return .max
    case "Min":
        return .min
    default:
        return .add
    }
}

func unOptypeConverter(type: String) -> EGUnaryOp.UnaryOpType {
    switch type {
    case "Sin":
        return .sin
    case "Cos":
        return .cos
    case "Tan":
        return .tan
        
    //not sure if cases below are corret
    case "Neg":
        return .neg
    case "Abs":
        return .abs
    default:
        return .sin
    }
}

func applyTransform(shape: EGGraphicsNode, transform: [EGMathNode], transformType: String) -> EGGraphicsNode {
    let shape = shape as! EGModel

    switch transformType{
    case "Translate":
        shape.transform.translate.set(x: transform[0], y: transform[1], z: transform[2])
        print("Applied Translate")
    case "Scale":
        shape.transform.scale.set(x: transform[0], y: transform[1], z: transform[2])
        print("Applied Scale")
    case "Rotate3D":
        shape.transform.rotate.set(x: transform[0], y: transform[1], z: transform[2])
        print("Applied Rotation")
    default:
        break
    }
    return shape
}

func inkedHelper(node: EINode) -> EGGraphicsNode{
    var color = [EGMathNode]()
    var isColored = false
    var shape = EGGraphicsNode()
    let inked = node as! EIAST.ConstructorInstance
    for param in inked.parameters{
        let inst = param as! EIAST.ConstructorInstance
        switch inst.constructorName{
        case "Just":
            isColored = true
            color = colorHelper(node: inst.parameters[0])
        case "Sphere":
            shape = EGSphere()
            print("Created Sphere")
        case "Cube":
            shape = EGCube()
            print("Created Cube")
        case "Polygon":
            print("Created Polygon")
            shape = EGRegularPolygon(unwrapInt(wrappedInt: inst.parameters[0]))
        case "Cone":
            shape = EGCone()
            print("Created Cone")
        case "Cylinder":
            shape = EGCylinder()
            print("Created Cylinder")
        case "Capsule":
            shape = EGCapsule()
            print("Created Capsule")
        default:
            break
        }
    }
    
    let model = shape as! EGModel
    if isColored{
        if color.count == 4{
            model.submeshColorMap[0] = EGColorProperty()
            model.submeshColorMap[0]?.set(r: color[0], g: color[1], b: color[2], a: color[3])
            print("coloured shape")
        }
        else{
            model.submeshColorMap[0] = EGColorProperty()
            model.submeshColorMap[0]?.set(r: color[0], g: color[1], b: color[2], a:EGConstant(1))
            print("coloured shape")
        }

    }
    return shape
}

func colorHelper(node: EINode) -> [EGMathNode]{
    var values = [EGConstant]()
    let colors = node as! EIAST.ConstructorInstance
    for value in colors.parameters{
        values.append(EGConstant(unwrapFloat(wrappedFloat: value)))
    }
    return values
}


func unwrapInt(wrappedInt: EINode) -> Int{
    let value = wrappedInt as! EIAST.Integer
    return Int(value.value)
}

func unwrapFloat(wrappedFloat: EINode) -> Float{
    if let value = wrappedFloat as? EIAST.FloatingPoint{
        return value.value
    }
    else {
        let value = wrappedFloat as! EIAST.Integer
        return Float(value.value)
    }
}

func unwrapTuple(wrappedTuple: EINode) -> simd_float3{
    var unwrappedTuple = simd_float3()
    let tuple = wrappedTuple as! EIAST.Tuple
    unwrappedTuple.x = Float(unwrapInt(wrappedInt: tuple.v1))
    unwrappedTuple.y = Float(unwrapInt(wrappedInt: tuple.v2))
    unwrappedTuple.z = Float(unwrapInt(wrappedInt: tuple.v3!))
    //More weird behaviour because ints are passed in but floats are needed for Metal API
    return unwrappedTuple
}

