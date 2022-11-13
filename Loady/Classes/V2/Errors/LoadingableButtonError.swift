//
//  LoadingableButtonError.swift
//  
//
//  Created by Farshad Jahanmanesh on 12/11/2022.
//

import Foundation
public enum LoadingableButtonError: Error{
    case typeOfAnimationIsNotProgressive(error: LoadingableError)
    case missingObjects(error: LoadingableError)
}
