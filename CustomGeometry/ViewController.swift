//
//  ViewController.swift
//  CustomGeometry
//
//  Created by CoderXu on 2018/2/27.
//  Copyright © 2018年 XanderXu. All rights reserved.
//

import UIKit
import SceneKit
import ModelIO
import SceneKit.ModelIO

extension MDLMaterial {
    func setTextureProperties(_ textures: [MDLMaterialSemantic:String]) -> Void {
        for (key,value) in textures {
            guard let url = Bundle.main.url(forResource: value, withExtension: "") else {
                fatalError("Failed to find URL for resource \(value).")
            }
            let property = MDLMaterialProperty(name:value, semantic: key, url: url)
            self.setProperty(property)
        }
    }
}

class ViewController: UIViewController {
    var scene = SCNScene()
    @IBOutlet weak var cubeView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cubeView.scene = scene;
        cubeView.backgroundColor = UIColor.gray
        cubeView.allowsCameraControl = true
        //camera摄像机
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 12, 50)
        cameraNode.rotation = SCNVector4Make(1, 0, 0, -sin(12/50.0))
        scene.rootNode.addChildNode(cameraNode)
        
        //加载立方体
        loadCube()
        //加载.obj格式文件
        loadFighter()
    }
    func loadCube() -> Void {
        //创建自定义几何体对象
        // ----------------------------------
        //先创建各种source
        let vertexSource = SCNGeometrySource(vertices:cubeVertices())
        let normalSource = SCNGeometrySource(normals:cubeNormals())
        let uvSource = SCNGeometrySource(textureCoordinates:cubeUVs())
        
        //创建三角形和线段的element
        //可直接创建Element
        let solidElement = SCNGeometryElement(indices: cubeSolidIndices(), primitiveType: .triangles)
        //或通过Data创建Element
        /*
         let ptr = UnsafeBufferPointer(start: cubeSolidIndices(), count: solidIndices.count)
         let solidIndexData = Data(buffer: ptr)//或直接用Data(bytes: solidIndices)
         let lineElement2 = SCNGeometryElement(data: solidIndexData, primitiveType: .triangles, primitiveCount: 12, bytesPerIndex: MemoryLayout<UInt8>.size)
         */
        
        let lineIndexData = Data(bytes: cubeLineIndices())
        let lineElement = SCNGeometryElement(data: lineIndexData, primitiveType: .line, primitiveCount: 18, bytesPerIndex: MemoryLayout<UInt8>.size)
        
        //创建几何体
        let geometry = SCNGeometry(sources: [vertexSource, normalSource, uvSource], elements: [solidElement,lineElement])
        
        
        //设置材质,面/线
        let solidMaterial = SCNMaterial()
        solidMaterial.diffuse.contents = UIColor(red: 4/255.0, green: 120.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        solidMaterial.locksAmbientWithDiffuse = true
        
        let lineMaterial = SCNMaterial()
        lineMaterial.diffuse.contents = UIColor.white
        lineMaterial.lightingModel = .constant
        
        geometry.materials = [solidMaterial,lineMaterial]
        
        
        let cubeNode = SCNNode(geometry: geometry)
        scene.rootNode.addChildNode(cubeNode)
    }
    
    
    func loadFighter() -> Void {
        // 加载.OBJ文件
        guard let url = Bundle.main.url(forResource: "Fighter", withExtension: "obj") else {
            fatalError("Failed to find model file.")
        }
        
        let asset = MDLAsset(url:url)
        guard let object = asset.object(at: 0) as? MDLMesh else {
            fatalError("Failed to get mesh from asset.")
        }
        
        // 创建各种纹理的材质
        let scatteringFunction = MDLScatteringFunction()
        let material = MDLMaterial(name: "baseMaterial", scatteringFunction: scatteringFunction)
        
        material.setTextureProperties([
            .baseColor:"Fighter_Diffuse_25.jpg",
            .specular:"Fighter_Specular_25.jpg",
            .emission:"Fighter_Illumination_25.jpg"])
        
        // 将纹理应用到每个网格上
        for  submesh in object.submeshes!  {
            if let submesh = submesh as? MDLSubmesh {
                submesh.material = material
            }
        }
        
        // 将ModelIO对象包装成SceneKit对象,调整大小和位置
        let node = SCNNode(mdlObject: object) //需要导入头文件`import SceneKit.ModelIO`
        node.scale = SCNVector3Make(0.05, 0.05, 0.05)
        node.position = SCNVector3Make(0, -20, 0)
        
        cubeView.scene?.rootNode.addChildNode(node)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func cubeVertices() -> [SCNVector3] {
        //cube立方体
        let cubeSide : Float = 15.0;
        let halfSide = cubeSide/2.0;
        
        let vertices:[SCNVector3] = [
            SCNVector3Make(-halfSide, -halfSide,  halfSide),
            SCNVector3Make( halfSide, -halfSide,  halfSide),
            SCNVector3Make(-halfSide, -halfSide, -halfSide),
            SCNVector3Make( halfSide, -halfSide, -halfSide),
            SCNVector3Make(-halfSide,  halfSide,  halfSide),
            SCNVector3Make( halfSide,  halfSide,  halfSide),
            SCNVector3Make(-halfSide,  halfSide, -halfSide),
            SCNVector3Make( halfSide,  halfSide, -halfSide),
            
            // 重复
            SCNVector3Make(-halfSide, -halfSide,  halfSide),
            SCNVector3Make( halfSide, -halfSide,  halfSide),
            SCNVector3Make(-halfSide, -halfSide, -halfSide),
            SCNVector3Make( halfSide, -halfSide, -halfSide),
            SCNVector3Make(-halfSide,  halfSide,  halfSide),
            SCNVector3Make( halfSide,  halfSide,  halfSide),
            SCNVector3Make(-halfSide,  halfSide, -halfSide),
            SCNVector3Make( halfSide,  halfSide, -halfSide),
            
            // 重复
            SCNVector3Make(-halfSide, -halfSide,  halfSide),
            SCNVector3Make( halfSide, -halfSide,  halfSide),
            SCNVector3Make(-halfSide, -halfSide, -halfSide),
            SCNVector3Make( halfSide, -halfSide, -halfSide),
            SCNVector3Make(-halfSide,  halfSide,  halfSide),
            SCNVector3Make( halfSide,  halfSide,  halfSide),
            SCNVector3Make(-halfSide,  halfSide, -halfSide),
            SCNVector3Make( halfSide,  halfSide, -halfSide)
        ]
        
        return vertices
    }
    func cubeNormals() -> [SCNVector3] {
        //法线
        let normals:[SCNVector3] = [
            // up and down
            SCNVector3Make( 0, -1, 0),
            SCNVector3Make( 0, -1, 0),
            SCNVector3Make( 0, -1, 0),
            SCNVector3Make( 0, -1, 0),
            
            SCNVector3Make( 0, 1, 0),
            SCNVector3Make( 0, 1, 0),
            SCNVector3Make( 0, 1, 0),
            SCNVector3Make( 0, 1, 0),
            
            // back and front
            SCNVector3Make( 0, 0,  1),
            SCNVector3Make( 0, 0,  1),
            SCNVector3Make( 0, 0, -1),
            SCNVector3Make( 0, 0, -1),
            
            SCNVector3Make( 0, 0, 1),
            SCNVector3Make( 0, 0, 1),
            SCNVector3Make( 0, 0, -1),
            SCNVector3Make( 0, 0, -1),
            
            // left and right
            SCNVector3Make(-1, 0, 0),
            SCNVector3Make( 1, 0, 0),
            SCNVector3Make(-1, 0, 0),
            SCNVector3Make( 1, 0, 0),
            
            SCNVector3Make(-1, 0, 0),
            SCNVector3Make( 1, 0, 0),
            SCNVector3Make(-1, 0, 0),
            SCNVector3Make( 1, 0, 0),
            ]
        return normals
    }
    
    func cubeUVs() -> [CGPoint] {
        //UVs
        let UVs:[CGPoint] = [
            
            CGPoint(x:0, y:0), // bottom
            CGPoint(x:1, y:0), // bottom
            CGPoint(x:0, y:1), // bottom
            CGPoint(x:1, y:1), // bottom
            
            CGPoint(x:0, y:1), // top
            CGPoint(x:1, y:1), // top
            CGPoint(x:0, y:0), // top
            CGPoint(x:1, y:0), // top
            
            CGPoint(x:0, y:1), // front
            CGPoint(x:1, y:1), // front
            CGPoint(x:1, y:1), // back
            CGPoint(x:0, y:1), // back
            
            CGPoint(x:0, y:0), // front
            CGPoint(x:1, y:0), // front
            CGPoint(x:1, y:0), // back
            CGPoint(x:0, y:0), // back
            
            CGPoint(x:1, y:1), // left
            CGPoint(x:0, y:1), // right
            CGPoint(x:0, y:1), // left
            CGPoint(x:1, y:1), // right
            
            CGPoint(x:1, y:0), // left
            CGPoint(x:0, y:0), // right
            CGPoint(x:0, y:0), // left
            CGPoint(x:1, y:0), // right
        ]
        return UVs
    }
    //返回值为[UInt8],Int型范围过大会出错
    func cubeSolidIndices() -> [UInt8] {
        //六个面索引,共12个三角形的索引
        let solidIndices:[UInt8] = [
            // bottom
            0, 2, 1,
            1, 2, 3,
            // back
            10, 14, 11,  // 2, 6, 3,   + 8
            11, 14, 15,  // 3, 6, 7,   + 8
            // left
            16, 20, 18,  // 0, 4, 2,   + 16
            18, 20, 22,  // 2, 4, 6,   + 16
            // right
            17, 19, 21,  // 1, 3, 5,   + 16
            19, 23, 21,  // 3, 7, 5,   + 16
            // front
            8,  9, 12,  // 0, 1, 4,   + 8
            9, 13, 12,  // 1, 5, 4,   + 8
            // top
            4, 5, 6,
            5, 7, 6
        ]
        return solidIndices
    }
    
    func cubeLineIndices() -> [UInt8] {
        //12条棱+6个面分割线,共18条线的索引
        let lineIndices:[UInt8] = [
            // bottom
            0, 1,
            0, 2,
            1, 3,
            2, 3,
            // top
            4, 5,
            4, 6,
            5, 7,
            6, 7,
            // sides
            0, 4,
            1, 5,
            2, 6,
            3, 7,
            // diagonals
            0, 5,
            1, 7,
            2, 4,
            3, 6,
            1, 2,
            4, 7
        ]
        return lineIndices
    }
}

