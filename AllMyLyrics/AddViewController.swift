//
//  AddViewController.swift
//  AllMyLyrics
//
//  Created by RAQUEL CHAMORRO GIGANTO on 04/05/2021.
//

import UIKit
import CoreData

class AddViewController: UIViewController {

    var cancion = ""
    var artista = ""
    var lyrics = ""
    
    @IBOutlet weak var tituloCancion: UITextField!
    @IBOutlet weak var artistaCancion: UITextField!
    @IBOutlet weak var letraCancion: UITextView!
    @IBOutlet weak var guardar: UIButton!
    @IBAction func cleanText(_ sender: Any) {
        
        letraCancion.text = ""
    }
    let gradientLayer = CAGradientLayer()
    var coreDataStack: CoreDataStack!
    var managedContext: NSManagedObjectContext!
    {
        get
        {
            return coreDataStack.context
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gradientLayer.colors = [UIColor(red: 0.53, green: 0.80, blue: 1.00, alpha: 1.00).cgColor, UIColor(red: 0.86, green: 0.66, blue: 1.00, alpha: 1.00).cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            gradientLayer.frame = view.bounds
    }
    
    func addAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title,
            message: message,
            preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "De acuerdo",
            style: .default,
            handler: { (action:UIAlertAction) -> Void in
        })
            
        alert.addAction(acceptAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        cancion = tituloCancion.text!
        artista = artistaCancion.text!
        lyrics = letraCancion.text!
        
        if cancion.isEmpty || artista.isEmpty || lyrics.isEmpty {
            
            addAlert(title: "Campos requeridos", message: "Tienes que rellenar todos los campos para poder guardar la canción.")
            
        } else {
            
            let entitySong = NSEntityDescription.entity(forEntityName: "Song",
                in:managedContext)!
            let entityArtist = NSEntityDescription.entity(forEntityName: "Artist",
                in:managedContext)!
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Song")
            let predicate = NSPredicate(format: "lyrics == %@", lyrics)
            fetchRequest.predicate = predicate
            fetchRequest.fetchLimit = 1
            
            do {
                let count = try managedContext.count(for: fetchRequest)
                if count == 0 {
                    //guardar objeto en bbdd
                    let song = Song(entity: entitySong,
                        insertInto: managedContext)
                    let artist = Artist(entity: entityArtist,
                        insertInto: managedContext)
                    
                    artist.name = self.artista.uppercased()
                    song.title = self.cancion.uppercased()
                    song.lyrics = self.lyrics
                    song.songArtist = artist
                    
                    coreDataStack.saveContext()
                    
                    let alert = UIAlertController(title: "Canción guardada",
                        message: "Pulsa en 'ver lista' para ver la canción",
                        preferredStyle: .alert)
                    
                    let acceptAction = UIAlertAction(title: "Ver lista",
                        style: .default,
                        handler: { (action:UIAlertAction) -> Void in
                            
                            self.performSegue(withIdentifier: "songList", sender: self)
                            
                    })
                    
                    let cancelAction = UIAlertAction(title: "Cancelar",
                        style: .cancel,
                        handler: { (action:UIAlertAction) -> Void in
                    })
                        
                    alert.addAction(acceptAction)
                    alert.addAction(cancelAction)
                    present(alert, animated: true, completion: nil)
                    
                }else{ //ya existe
                    
                    addAlert(title: "Canción ya existente", message: "Esta canción ya está guardada en la base de datos.")
                    
                }
                
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
                addAlert(title: "Error", message: "No se ha podido guardar la canción en la base de datos.")
            }
            
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        guard let lVC = segue.destination as? ListViewController
            else {
                return
        }
        
        lVC.coreDataStack = coreDataStack
    }
    

}
