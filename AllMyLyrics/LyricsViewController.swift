//
//  LyricsViewController.swift
//  AllMyLyrics
//
//  Created by RAQUEL CHAMORRO GIGANTO on 09/04/2021.
//

import UIKit
import CoreData

class LyricsViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var artistaLabel: UILabel!
    @IBOutlet weak var tituloLabel: UILabel!
    @IBOutlet weak var save: UIButton!
    
    var titulo = ""
    var artista = ""
    var lyrics = ""
    var segueSearch: Bool = false
    let gradientLayer = CAGradientLayer()
    var canciones: [Song] = []
    var coreDataStack: CoreDataStack!
    var managedContext: NSManagedObjectContext!
    {
        get
        {
            return coreDataStack.context
        }
    }
    @IBAction func showLista(_ sender: Any) {
    
        self.performSegue(withIdentifier: "segueLista", sender: self)
        
    }
    @IBAction func save(_ sender: Any) {
        
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
                
                artist.name = self.artistaLabel.text
                song.title = self.tituloLabel.text
                song.lyrics = self.display.text
                song.songArtist = artist
                
                coreDataStack.saveContext()
                
                addAlert(title: "Canción guardada", message: "Pulsa en 'ver lista' para ver la canción")
                
            }else{ //si ya existe
             
                addAlert(title: "Canción ya existente", message: "Esta canción ya está guardada en la base de datos.")
            
            }
            
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
            addAlert(title: "Error", message: "No se ha podido guardar la canción en la base de datos.")
        }
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradientLayer.colors = [UIColor(red: 0.53, green: 0.80, blue: 1.00, alpha: 1.00).cgColor, UIColor(red: 0.86, green: 0.66, blue: 1.00, alpha: 1.00).cgColor]
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        tituloLabel.text = titulo
        artistaLabel.text = artista
        display.text = lyrics
    }
    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            gradientLayer.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(segueSearch) { //desde la pantalla de búsqueda
            save.isEnabled = true
        }else{ //desde la pantalla del listado
            save.isEnabled = false
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        
        case "segueLista":
            guard let lVC = segue.destination as? ListViewController else {
                return
            }
            
            lVC.coreDataStack = coreDataStack
            
        default:
            print("Unknown segue id: \(segue.identifier!)")
        }
    }

}
