//
//  ListViewController.swift
//  AllMyLyrics
//
//  Created by RAQUEL CHAMORRO GIGANTO on 13/04/2021.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let gradientLayer = CAGradientLayer()
    var canciones: [Song] = []
    var songsDictionary = [String: [Song]]() // ["a": [asong, asong2],...]
    var songSectionTitles = [String]() // ["a", "b", ...]
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
        self.tableView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        let fetchRequest = NSFetchRequest<Song>(entityName: "Song")
        let songSortDescriptor = NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.localizedCompare(_:)))
        
        do {
           
            fetchRequest.sortDescriptors = [songSortDescriptor]
            canciones = try managedContext.fetch(fetchRequest)
            
            for cancion in canciones {
                let primeraLetra = String((cancion.title?.prefix(1))!)
                if var songValues = songsDictionary[primeraLetra] {
                    songValues.append(cancion)
                    songsDictionary[primeraLetra] = songValues
                }else{
                    songsDictionary[primeraLetra] = [cancion]
                }
            }
            
            songSectionTitles = [String](songsDictionary.keys)
            songSectionTitles = songSectionTitles.sorted(by: {$0 < $1})
           
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            gradientLayer.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        coreDataStack.saveContext()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return songSectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return songSectionTitles[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return songSectionTitles
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let songKey = songSectionTitles[section]
        if let songValues = songsDictionary[songKey] {
            return songValues.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celda_lyrics", for: indexPath) as! CustomCell
        
        let songkey = songSectionTitles[indexPath.section]
        
        if let songValues = songsDictionary[songkey] {
            let cancion = songValues[indexPath.row]
            cell.titulo.text = cancion.title
            cell.artista.text = cancion.songArtist?.name
            cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        guard editingStyle == .delete else {
            return
        }
        
        
        let songkey = songSectionTitles[indexPath.section]
        
        if let songValues = songsDictionary[songkey] {
            
            let cancion = songValues[indexPath.row]
            managedContext.delete(cancion)
            songsDictionary[songkey]?.remove(at: indexPath.row)
            
            do {
                try managedContext.save()
                coreDataStack.saveContext()
                
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            canciones.remove(at: indexPath.row)
            tableView.reloadData()
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "segueToLyrics":
            
            guard let lVC = segue.destination as? LyricsViewController,
                let cell = sender as? CustomCell,
                let indexPath = tableView.indexPath(for: cell)
                
                else {
                    return
            }
            
            let songkey = songSectionTitles[indexPath.section]
            
            if let songValues = songsDictionary[songkey] {
                let cancion = songValues[indexPath.row]
                lVC.titulo = cancion.title!
                lVC.artista = (cancion.songArtist?.name)!
                lVC.lyrics = cancion.lyrics!
            }
            
            lVC.coreDataStack = coreDataStack
             
        case "addSong":
            guard let aVC = segue.destination as? AddViewController
                else {
                    return
            }
            
            aVC.coreDataStack = coreDataStack
            
        default:
            print("Unknown segue id: \(segue.identifier!)")
        }
        
    }
    
}

