//
//  main.swift
//  FontChanger
//
//  Created by Fidel Sosa on 2/3/15.
//  Copyright (c) 2015 fsosa. All rights reserved.
//

import Foundation

// immediate child of document <<<
//<customFonts key="customFonts">
//<mutableArray key="SourceSansPro-Regular.otf">
//<string>SourceSansPro-Regular</string>
//<string>SourceSansPro-Regular</string>
//<string>SourceSansPro-Regular</string>
//<string>SourceSansPro-Regular</string>
//<string>SourceSansPro-Regular</string>
//<string>SourceSansPro-Regular</string>
//<string>SourceSansPro-Regular</string>
//</mutableArray>
//</customFonts>

// <fontDescription key="fontDescription" type="system" pointSize="17"/>
// <fontDescription key="fontDescription" name="SourceSansPro-Regular" family="Source Sans Pro" pointSize="16"/>



func start()
{
    // TODO: Find all xibs
    let filePath = "~/Dev/GuestCenter-iPad/Classes/LoginViewController.xib".stringByExpandingTildeInPath
    let xibURL = NSURL(fileURLWithPath: filePath);
    
    let xmlDoc = xmlDocumentForURL(xibURL);
    
    let fontNodes = xmlDoc?.nodesForXPath(".//fontDescription", error: nil)
    
    // Update with correct mapping
    let fontTransform = ["system" : "TheFidelFont-Regular",
                         "HelveticaNeue-Medium" : "TheFidelFont-Medium"];
    
    var usedFonts: NSMutableArray = [];
    if fontNodes != nil {
        for node in fontNodes! {
            if let fontDescription = node as? NSXMLElement {
                
                let type: AnyObject? = fontDescription.attributeForName("type")?.objectValue
                let pointSize: AnyObject? = fontDescription.attributeForName("pointSize")?.objectValue
                let name: AnyObject? = fontDescription.attributeForName("name")?.objectValue
                let family: AnyObject? = fontDescription.attributeForName("family")?.objectValue
                
                if type as? String == "system" {
                    let fontName: String = fontTransform[type as String]!
                    let attributes = ["key": "fontDescription",
                        "name": fontName,
                        "family": "TheFidelFontFamily",
                        "pointSize": (pointSize as? String)!];
                    
                    // keep track of used fonts for later
                    usedFonts.addObject(fontName)
                    
                    fontDescription.setAttributesWithDictionary(attributes)
                }
            }
        }
    }
    
    // TODO: add custom font declaration
//    var customElementNode: AnyObject? = NSXMLElement.elementWithName("customFonts")
//    var keyAttribute: AnyObject? = NSXMLNode.attributeWithName("key", stringValue: "customFonts")
//    customElementNode?.addAttribute(keyAttribute as NSXMLNode)
//    
//    var fontElement: AnyObject? = NSXMLElement.elementWithName("mutableArray")
    
    let xmlData = xmlDoc?.XMLDataWithOptions(Int(NSXMLNodeCompactEmptyElement) | Int(NSXMLNodePrettyPrint))
    let didWriteToFile = xmlData?.writeToFile("~/Desktop/test.xib".stringByExpandingTildeInPath, atomically: true)
    
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

start()






