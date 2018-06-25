//
//  ViewController.swift
//  ARDicee
//
//  Created by Adam Moore on 5/14/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Shows feature points as it is trying to detect a horizontal plane.
        // Helps to debug if you think you are having trouble detecting the horizontal plane.
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        
        
        
        
        // Set the view's delegate
        sceneView.delegate = self
        
        
        
        
        // **************************
        // *** Mark: - Cube and Sphere
        // **************************
        
        
        
        
        // In meters
        // 'chamferRadius' is how rounded the corners are.
        // Starts out as a matte white look.
        
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        
        let sphere = SCNSphere(radius: 0.2)
        
        
        // Changing the color of the object.
        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.red
        material.diffuse.contents = UIImage(named: "art.scnassets/8k_earth_daymap.jpg")
        
        
        
        // Add the material to the cube.
        // Takes an array of 'materials', as it can have multiple types of materials to design it.
        
//        cube.materials = [material]
        
        sphere.materials = [material]
        
        
        // Scene nodes are basically a 3D point in space.
        // '.position' is a 3D vector, with xyz axes
        // Then the '.geometry' is the 3D space that will sit on this space, i.e., our 'cube' geometry.
        let node = SCNNode()
        node.position = SCNVector3Make(0, 0.1, -1)
        
//        node.geometry = cube
        node.geometry = sphere
        
        
        // Now we have to put our 'node' into our 'sceneView'
        // Adding a child node to our root node in our 3D scene.
        sceneView.scene.rootNode.addChildNode(node)
        
        // Adds default shadow light to the object, to make it appear more natural in the surrounding.
        sceneView.autoenablesDefaultLighting = true
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        // **************************
        // *** Mark: - Dice
        // **************************
        
        
//        // Create a new scene
//        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
//
//        // 'withName' is the name in the identity section of the .scn image.
//        // Recursively searches through the tree and includes all of the subtrees in the child node.
//        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
//
//            diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1)
//
//            sceneView.scene.rootNode.addChildNode(diceNode)
//
//        }
        
        
        
        
        
        
        
//        // Set the scene to the view
//        sceneView.scene = scene
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        
        // Plane detection
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    
    
    
    
    // Detects touches on the screen to correspond with the place in the camera that we see for our AR.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        
        // We just get the first touch that was done from the 'touches' array that would be possible, including multiple touches, but we aren't interested in multiple touches, it is only the first touch that we are concerned with.
        if let touch = touches.first {
            
            
            
            // This is where our touch event was initiated.
            let touchLocation = touch.location(in: sceneView)
            
            
            // Searches for real world objects that correspond in the camera view to the place that was touched on the screen.
            // '.existingPlaneUsingExtent' is the existing plane that we created below in the 'renderer' function.
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            
            
            // We are checking here if some touch point in the hit test corresponded to one of the points in our horizontal plane.
            // 'results' returns an array, so we check to see if it is empty.
            // If it isn't, then we know that the hit point was somewhere on our horizontal plane, which we defined with the '.existingPlaneUsingExtent' that uses a plane anchor that is already in view.
            if let hitResult = results.first {

                addDice(atLocation: hitResult)
                
            }
            
        }
        
    }
    
    
    func addDice(atLocation: ARHitTestResult) {
        
        // *** This creates a new dice on the spot that the user taps, each time they tap.
        
        
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        // 'withName' is the name in the identity section of the .scn image.
        // Recursively searches through the tree and includes all of the subtrees in the child node.
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            
            
            
            // The 'worldTransform' property is a 4x4 grid that resulted from the 'hitResult', with the first 3 columns being x,y,z, and the 4th being the position.
            // So, we choose 'columns' and then the last one, '3', and the x, y, z positions for the respective constants.
            
            // The dice is initially created with the 'y' position being flush with the elevation of the plane, so it is right in the middle of the plane. We need to raise it half the size of the dice, to bring it to the top of the plane, so that it's sitting on top of the horizontal plane, using the 'diceNode.boundingSphere.radius' property to get the radius of the 'diceNode' that we created.
            
            let x = atLocation.worldTransform.columns.3.x
            let y = atLocation.worldTransform.columns.3.y + diceNode.boundingSphere.radius
            let z = atLocation.worldTransform.columns.3.z
            
            diceNode.position = SCNVector3(x: x, y: y, z: z)
            
            diceArray.append(diceNode)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            
            roll(dice: diceNode)
            
        }
        
    }
    
    
    func rollAll() {
        
        if !diceArray.isEmpty {
            
            for dice in diceArray {
                
                roll(dice: dice)
                
            }
            
        }
        
    }
    
    
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        
        rollAll()
        
    }
    
    
    // Used for shaking the phone and the motion has ended.
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        
        rollAll()
        
    }
    
    
    // Removes all of the objects from the parent node, so it removes all of the dice out of the picture.
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        
        if !diceArray.isEmpty {
            
            for dice in diceArray {
                
                dice.removeFromParentNode()
                
            }
            
        }
        
    }
    
    
    func roll(dice: SCNNode) {
        
        // 'arc4random_uniform(4) + 1' to get numbers 1, 2, 3, & 4, because this is the rotation along the 'x' & 'z' axis., as there are 4 sides that can show when it rotates along the 'x' and 'z' axis.
        // This is NOT for all 6 sides of the dice.
        // It is multiplied by 'Float.pi/2' because this would be the equivalent of 90°, so that the side shows up.
        // It rotates along the axes as if the axis was going THROUGH the dice, and it was spinning on it.
        // So, the 'y' axis is unnecessary, because that would basically be it spinning, which wouldn't change the number on the face of it.
        
        let randomX = Float((arc4random_uniform(4) + 1)) * (Float.pi/2)
        
        let randomZ = Float((arc4random_uniform(4) + 1)) * (Float.pi/2)
        
        
        
        // SCNKit has a function called 'runAnimation' that we can use to animate this rotation.
        // Multiplying by '5' causes it to spin more than just in the 4 sets of circular degrees that we set. In other words, it spins it around more than once, possibly, up to 5 times, always being at a right angle, because of the 'Float.pi/2' that we set as 90°
        
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 1.0))
        
    }
    
    
    
    
    
    // MARK: - ARSCNDelegateMethods
    
    
    // ARSCNViewDelegate method that we need for horizontal detection.
    // The 'anchor' parameter is what finds the horizontal plane.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // Checks if it is of the type 'ARPlaneAnchor'
        // Downcasts it as 'ARPlaneAnchor' if it is of this type, changing it from 'ARAnchor' to 'ARPlaneAnchor'.
        // Basically, 'ARAnchor' is the granddad, and 'ARPlaneAnchor' is the dad, but we are making is function here specifically in the role of 'dad, not the designated one of the function, which is 'granddad'
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        
        
        // Adds our 'planeNode' to the blank 'node' that we are creating with this function.
        node.addChildNode(planeNode)
        
    }
    
    
    // MARK: - Plane Rendering Method
    
    func createPlane(withPlaneAnchor: ARPlaneAnchor) -> SCNNode{
        
        // Convert our 'planeAnchor' into a 'SCNPlane'
        // The 'anchor' is basically like a tile on the ground, so it has a width and a height, which we'll use to create the plane.
        // CANNOT USE 'y', as you would think; has to use 'x' and 'z' for the width and height, respectively. The reason is is because we are using 3d space. therefore, the 'x' axis is left to right, as you'd expect, the 'y' is up and down, and the 'z' is closer or further from the user. Therfore, when we look at a horizontal plane, with a width and a length, we are talking about how wide it is from left to right ('x'), but the height of it isn't how far it is off of the ground, but how far away from us it is, i.e., the 'z' position. The 'y' position, in this instance, would be how tall it is, but that isn't a concern for us when detecting horizontal planes, as we just need to know how big it is from left to right ('x') and and far away from us it is from the start to the end ('z').
        let plane = SCNPlane(width: CGFloat(withPlaneAnchor.extent.x), height: CGFloat(withPlaneAnchor.extent.z))
        
        
        
        // Next, we have to create a node, as we did with the cube and the sphere.
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(x: withPlaneAnchor.center.x, y: 0, z: withPlaneAnchor.center.z)
        
        
        
        // Have to transform the planeNode, which is naturally vertical, to a horizontal node by rotating it so that it is flat. As it stands, vertical, it has an 'x' and 'y' value, but we need to rotate it to have an 'x' and 'z' value.
        // The first parameter, the angle, is in radians, or 1π radian = 180°.
        // This rotates by '-Float.pi/2' 90° clockwise.
        // Only transforms around the 'x' axis, so it has a value of 1.
        planeNode.transform = SCNMatrix4MakeRotation(Float.pi/2, 1, 0, 0)
        
        
        
        // Sets up the material to use for the 'plane'.
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        
        
        
        // Add the material to the plane.
        // Takes an array of 'materials', as it can have multiple types of materials to design it.
        plane.materials = [gridMaterial]
        
        
        
        
        // Then the '.geometry' is the 3D space that will sit on this space, i.e., our 'cube' geometry.
        planeNode.geometry = plane
        
        
        
        return planeNode

        
        
    }
    
}













