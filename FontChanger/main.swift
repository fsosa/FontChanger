//
//  main.swift
//  FontChanger
//
//  Created by Fidel Sosa on 2/3/15.
//  Copyright (c) 2015 fsosa. All rights reserved.
//

import Foundation

// Example custom font element
//
//<customFonts key="customFonts">
//  <mutableArray key="SourceSansPro-Regular.otf">
//      <string>SourceSansPro-Regular</string>
//      <string>SourceSansPro-Regular</string>
//      <string>SourceSansPro-Regular</string>
//      <string>SourceSansPro-Regular</string>
//      <string>SourceSansPro-Regular</string>
//      <string>SourceSansPro-Regular</string>
//      <string>SourceSansPro-Regular</string>
//  </mutableArray>
//</customFonts>


// Example fontDescription element
//
// <fontDescription key="fontDescription" type="system" pointSize="17"/>
// <fontDescription key="fontDescription" name="SourceSansPro-Regular" family="Source Sans Pro" pointSize="16"/>

func start()
{
    // Find all xibs
    var error: NSError?
    let baseDir = "~/Dev/GuestCenter-iPad/Classes".stringByExpandingTildeInPath
    let directoryContents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(baseDir, error: &error)
    
    if (error != nil) {
        println(error)
        return;
    }

    if directoryContents != nil {
        for filePath in directoryContents! {
            if filePath.hasSuffix(".xib") {
                let fullPath = "\(baseDir)/\(filePath)"
                updateXibAtFilePath(fullPath)
            }
        }
    }

}


func updateXibAtFilePath(filePath: String)
{
    let filePath = filePath.stringByExpandingTildeInPath
    let xibURL = NSURL(fileURLWithPath: filePath);
    
    let xmlDoc = xmlDocumentForURL(xibURL);
    
    let fontNodes = xmlDoc?.nodesForXPath(".//fontDescription", error: nil)
    
    // TODO: Update with correct mapping
    let fontTransform = ["system" : "SourceSansPro-Regular",
                         "HelveticaNeue-Medium" : "SourceSansPro-Regular"];
    
    // TODO: Update with correct source file mapping
    let fontSource:NSDictionary = ["SourceSansPro-Regular": "SourceSansPro-Regular.otf"];
    
    var usedFonts: NSMutableDictionary = NSMutableDictionary()
    if fontNodes != nil {
        for node in fontNodes! {
            if let fontDescription = node as? NSXMLElement {
                
                let type: AnyObject? = fontDescription.attributeForName("type")?.objectValue
                let pointSize: AnyObject? = fontDescription.attributeForName("pointSize")?.objectValue
                let name: AnyObject? = fontDescription.attributeForName("name")?.objectValue
                let family: AnyObject? = fontDescription.attributeForName("family")?.objectValue
                
                for (originalFont, newFont) in fontTransform {
                    if type as? String == originalFont || name as? String == originalFont {
                        let attributes = ["key": "fontDescription", "name": newFont, "family": "Source Sans Pro", "pointSize": (pointSize as? String)!];

                        // keep track of used fonts for later
                        if (usedFonts[newFont] != nil) {
                            var counter  = usedFonts[newFont] as Int
                            counter++
                            usedFonts[newFont] = counter
                        } else {
                            usedFonts[newFont] = 1
                        }
                        
                        fontDescription.setAttributesWithDictionary(attributes)
                    }
                }
            }
        }
    }
    
    
    // Add the custom font declaration, once for each instance of the font
    var customElementNode: AnyObject? = NSXMLElement.elementWithName("customFonts")
    let keyAttribute: AnyObject? = NSXMLNode.attributeWithName("key", stringValue: "customFonts")
    customElementNode?.addAttribute(keyAttribute as NSXMLNode)
    println(usedFonts)
    
    for (usedFont, counter) in usedFonts {
        var fontElement: AnyObject? = NSXMLElement.elementWithName("mutableArray")
        if (fontSource.objectForKey(usedFont) == nil) {
            continue;
        }
        let source: AnyObject? = fontSource.objectForKey(usedFont)
        let sourceFileAttribute: AnyObject? = NSXMLNode.attributeWithName("key", stringValue: source as String)
        fontElement?.addAttribute(sourceFileAttribute as NSXMLNode)
        
        for var i = 0; i < counter as Int; i++ {
            let fontNameNode: AnyObject? = NSXMLElement.elementWithName("string", stringValue: usedFont as String)
            fontElement?.addChild(fontNameNode as NSXMLNode)
        }
        
        customElementNode!.addChild(fontElement as NSXMLNode)
    }
    
    let docNodes = xmlDoc?.nodesForXPath("/document", error: nil)
    docNodes?.first?.addChild(customElementNode as NSXMLNode)
    
    let xmlData = xmlDoc?.XMLDataWithOptions(Int(NSXMLNodeCompactEmptyElement) | Int(NSXMLNodePrettyPrint))
    let didWriteToFile = xmlData?.writeToFile(filePath, atomically: true)
    
    if didWriteToFile == true {
        println("wrote to file successfully")
    } else {
        println("something went wrong writing")
    }
}

// MARK: Utility functions

func xmlDocumentForURL(url: NSURL?) -> NSXMLDocument?
{
    if url == nil {
        return nil;
    }
    
    // Open the XIB as an XML document
    var error: NSError?
    let xmlDoc = NSXMLDocument(contentsOfURL: url!, options: 0, error: &error)
    
    if error != nil {
        println("the error was \(error)")
        return nil;
    }
    
    return xmlDoc;
}

// RUN THAT SHIT FAST
start()






