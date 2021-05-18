//
//  ViewController.swift
//  AllMyLyrics
//
//  Created by RAQUEL CHAMORRO GIGANTO on 14/03/2021.
//

import UIKit
import CoreData
import DesignSystem

class ViewController: UIViewController {
    var cancion = ""
    var artista = ""
    var lyrics = ""
    
    @IBOutlet weak var artistaCancion: UITextField!
    @IBOutlet weak var titCancion: UITextField!
    @IBOutlet weak var botonSearch: UIButton!
    @IBOutlet weak var circle: UIView!
    @IBOutlet weak var texto: UILabel!
    @IBOutlet weak var verLista: UIBarButtonItem!

    
    let gradientLayer = CAGradientLayer()
    var coreDataStack: CoreDataStack!
    var managedContext: NSManagedObjectContext!
    {
        get
        {
            return coreDataStack.context
        }
    }
    
    func urlFormatting(text:String) -> String {
        
        let urlEncoded = text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!.replacingOccurrences(of: "&", with: "and")
        return urlEncoded
    }
    
    @IBAction func send(_ sender: Any) {
        cancion = titCancion.text!
        artista = artistaCancion.text!
        
        APILyrics().pedirLyrics(artista: urlFormatting(text: artista), cancion: urlFormatting(text:cancion)) { (resultado) in
            switch resultado {
            case let .success(lyricsBien):
                self.lyrics = lyricsBien.lyrics
                self.performSegue(withIdentifier: "segueLyrics", sender: self)
            case let .failure(error):
                print("error")
                print(error)
                self.lanzarError()
                
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        
        case "segueLyrics":
            guard let dVC = segue.destination as? LyricsViewController else {
                return
            }
            
            dVC.lyrics = lyrics
            dVC.artista = artista.uppercased()
            dVC.titulo = cancion.uppercased()
            dVC.segueSearch = true
            dVC.coreDataStack = coreDataStack
        
        case "segueList":
            guard let lVC = segue.destination as? ListViewController else {
                return
            }
            
            lVC.coreDataStack = coreDataStack
            
        case "addSong":
            guard let aVC = segue.destination as? AddViewController else {
                return
            }
            
            aVC.coreDataStack = coreDataStack
        default:
            print("Unknown segue id: \(segue.identifier!)")
        }
        
    }
    
    func lanzarError() {
        
        let alert = UIAlertController(title: "Error de búsqueda",
            message: "Parece que la canción o artista/s introducidos no arrojan ningún resultado. Comprueba que los valores estén bien escritos.",
            preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "De acuerdo",
            style: .default,
            handler: { (action:UIAlertAction) -> Void in
        })
            
        alert.addAction(acceptAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gradientLayer.colors = [UIColor(red: 0.53, green: 0.80, blue: 1.00, alpha: 1.00).cgColor, UIColor(red: 0.86, green: 0.66, blue: 1.00, alpha: 1.00).cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        botonSearch.layer.cornerRadius = 15
        botonSearch.layer.opacity = 0.4
        circle.layer.cornerRadius = circle.layer.bounds.width / 2
        texto.font = UIFont.sldsFont(.regular, with: .fontSizeHeadingSmall)

    }
    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            gradientLayer.frame = view.bounds
    }
    
}



