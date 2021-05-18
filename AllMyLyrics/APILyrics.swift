//
//  APILyrics.swift
//  AllMyLyrics
//
//  Created by RAQUEL CHAMORRO GIGANTO on 26/03/2021.
//

import Foundation
import Alamofire


struct Resultado: Decodable {
    var lyrics: String
}

class APILyrics {
    
    var session = Session.default
    
    func pedirLyrics(artista: String, cancion: String, completion: @escaping (Result<Resultado, AFError>)->()) {
        session.request("https://api.lyrics.ovh/v1/"+artista+"/"+cancion, method: .get).validate().responseDecodable(of: Resultado.self) { (resultado) in completion(resultado.result)
        }
    }
    
}


