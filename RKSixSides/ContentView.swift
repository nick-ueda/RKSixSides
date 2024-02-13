//
//  ContentView.swift
//  RKCubeRotation
//

import SwiftUI
import RealityKit
import Combine

class CubeState {
    var rotation: Float = .zero
}

class CubeSpaceView: ARView {
    var arView: ARView {return self}
    private var cubeUpdate: Cancellable?
    var cubeState = CubeState()
    
    @MainActor required dynamic override init(frame frameRect: CGRect, cameraMode: ARView.CameraMode, automaticallyConfigureSession: Bool) {
        cubeState.rotation = 0
        super.init(frame: frameRect, cameraMode: cameraMode, automaticallyConfigureSession: automaticallyConfigureSession)
    }
    
    @MainActor required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor required dynamic init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    func getSingleCube(x:Float, y:Float, z:Float, mesh:MeshResource, materials:[SimpleMaterial]) -> ModelEntity {
        let model = ModelEntity(mesh: mesh, materials: materials)
        model.position.x = x
        model.position.y = y
        model.position.z = z
        model.name = "Cube"
        model.generateCollisionShapes(recursive: true)
        return model
    }

    func getSinglePlane(width: Float, depth: Float, color: UIColor, x:Float, y:Float, z:Float, rotationAngle:Float, rotationAxis:SIMD3<Float>) -> ModelEntity {
        let planeMesh = MeshResource.generatePlane(width: width, depth: depth)
        let planeMaterial = SimpleMaterial(color: color, roughness: 0.0, isMetallic: false)
        let planeEntity = ModelEntity(mesh: planeMesh, materials: [planeMaterial])
        let planeRotation = simd_quatf(angle: rotationAngle, axis: rotationAxis)
        let planeTransform = Transform(scale:.one, rotation: planeRotation, translation: SIMD3<Float>(x,y,z))
        planeEntity.transform = planeTransform
        return planeEntity
    }
    
    func setup(){

        let planeAnchor = AnchorEntity(world: [0,0,0])
//        let xPlane = getSinglePlane(width: 10, depth: 10, color: .orange, x: 0, y: 2.5, z: 0, rotationAngle: Float(0),rotationAxis: SIMD3<Float>(0,0,0))
//        let yPlane = getSinglePlane(width: 10, depth: 10, color: .blue, x: 0, y: 2.5, z: 0, rotationAngle: Float(Double.pi / 2),rotationAxis: SIMD3<Float>(1,0,0))
//        let zPlane = getSinglePlane(width: 10, depth: 10, color: .orange, x: 0, y: 2.5, z: 0, rotationAngle: Float(Double.pi / 2),rotationAxis: SIMD3<Float>(0,0,1))

        let frontFace = getSinglePlane(width: 5, depth: 5, color: .yellow, x: 0, y: 0, z: 2.5, rotationAngle: Float(Double.pi / 2),rotationAxis: SIMD3<Float>(1,0,0))
        let bottomFace = getSinglePlane(width: 5, depth: 5, color: .red, x: 0, y: -2.5, z: 0, rotationAngle: Float(Double.pi),rotationAxis: SIMD3<Float>(1,0,0))
        let topFace = getSinglePlane(width: 5, depth: 5, color: .green, x: 0, y: 2.5, z: 0, rotationAngle: 0,rotationAxis: SIMD3<Float>(0,1,0))
        let leftFace = getSinglePlane(width: 5, depth: 5, color: .blue, x: -2.5, y: 0, z: 0, rotationAngle: Float(Double.pi / 2),rotationAxis: SIMD3<Float>(0,0,1))
        let rightFace = getSinglePlane(width: 5, depth: 5, color: .purple, x: 2.5, y: 0, z: 0, rotationAngle: -Float(Double.pi / 2),rotationAxis: SIMD3<Float>(0,0,1))
        let backFace = getSinglePlane(width: 5, depth: 5, color: .white, x: 0, y: 0, z: -2.5, rotationAngle: -Float(Double.pi / 2),rotationAxis: SIMD3<Float>(1,0,0))
        
        let axesAnchors = AnchorEntity(world: [0,0,0])
        //axesAnchors.addChild(xPlane)
        //axesAnchors.addChild(yPlane)
        //axesAnchors.addChild(zPlane)

        planeAnchor.addChild(frontFace)
        planeAnchor.addChild(bottomFace)
        planeAnchor.addChild(topFace)
        planeAnchor.addChild(leftFace)
        planeAnchor.addChild(rightFace)
        planeAnchor.addChild(backFace)
        axesAnchors.addChild(planeAnchor)
        
        arView.scene.addAnchor(axesAnchors)

        let camera = PerspectiveCamera()
        let cameraAnchor = AnchorEntity(world:[0,0,0])
        camera.look(at: SIMD3<Float>(x: 0, y: 0, z: 0), from: SIMD3<Float>(x: -5, y: 10, z: 10), relativeTo: nil)
        cameraAnchor.addChild(camera)
        arView.scene.addAnchor(cameraAnchor)
        var anchorAngle = 0.0

        self.cubeUpdate = scene.subscribe(to: SceneEvents.Update.self) { event in
            anchorAngle = anchorAngle + 0.004
            let anchorRotation = simd_quatf(angle: Float(anchorAngle), axis: SIMD3<Float>(1,0,0))
            let anchorTransform = Transform(scale:.one, rotation: anchorRotation, translation:SIMD3<Float>(0,0,0))
            planeAnchor.transform = anchorTransform
        }
    }
}

struct ContentView : View {
    @State private var cubeState = CubeState()
    var body: some View {
        VStack {
            ARViewContainer(cubeState).edgesIgnoringSafeArea(.all)
        }
    }
}


struct ARViewContainer: UIViewRepresentable {
    private var cubeState: CubeState

    public init(_ cubeState: CubeState){
        self.cubeState = cubeState
    }

    func makeUIView(context: Context) -> ARView {
        let arView = CubeSpaceView(frame: .zero, cameraMode: ARView.CameraMode.nonAR, automaticallyConfigureSession: false)
        arView.setup()
        arView.cubeState = cubeState
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}

#Preview {
    ContentView()
}
