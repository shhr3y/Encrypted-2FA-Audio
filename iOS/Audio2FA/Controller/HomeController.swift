//
//  HomeController.swift
//  Audio2FA
//
//  Created by Shrey Gupta on 26/10/22.
//

import UIKit

enum ActionButtonConfiguration {
    case showMenu
    case closeMenu
    
    init() {
        self = .showMenu
    }
}

protocol HomeControllerDelegate: AnyObject {
    func handleMenuToggle()
}

class HomeController: UIViewController {
    weak var delegate: HomeControllerDelegate?
    
    var user: User?
    
    private var actionButtonConfig = ActionButtonConfiguration()
    
    private let receivedMessage: UILabel = {
        let label = UILabel()
        label.text = "Received Message"
        return label
    } ()
    
    private lazy var sendMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send Message!", for: .normal)
        button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        return button
    } ()
    
    private lazy var authenticateButton: CircularProgressView = {
        let frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        let circularView = CircularProgressView(frame: frame)
        circularView.isUserInteractionEnabled = true
        circularView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendMessage)))
    
        circularView.addSubview(buttonCenterView)
        buttonCenterView.centerX(inView: circularView)
        buttonCenterView.centerY(inView: circularView)
        
        
        return circularView
    } ()
    
    private lazy var buttonCenterView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.8)
        view.setDimensions(height: 300 - 70, width: 300 - 70)
        view.layer.cornerRadius = (300 - 70)/2
        
        view.addSubview(lockImage)
        lockImage.setDimensions(height: 75, width: 75)
        lockImage.centerX(inView: view)
        lockImage.centerY(inView: view)
        return view
    } ()
    
    private let lockImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(imageLiteralResourceName: "icons8-lock-72")
        iv.image?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = .black
        return iv
    } ()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .backgroundColor
        
        TextToAudioWrapper.shared.delegate = self
        // Do any additional setup after loading the view.

        checkIfUserIsLoggedIn()
    }
    
    @objc func sendMessage() {
        guard let user = self.user else { return }
        guard let encryptedData = CryptLib().encryptPlainTextRandomIV(withPlainText: user.uid, key: user.getEncryptionKey()) else { return }

        authenticateButton.animatePulsatingLayer()
        authenticateButton.setProgressWithAnimation(duration: 3, value: 0) {
            self.authenticateButton.stopPulsatingAnimation()
            self.lockImage.image = UIImage(imageLiteralResourceName: "icons8-lock-72")
        }
        self.lockImage.image = UIImage(imageLiteralResourceName: "icons8-open-lock-72")
        TextToAudioWrapper.shared.broadCastText(encryptedData)
    }
    
    @objc func actionButtonPressed() {
        let sheet = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Settings", style: .default) { action in
            self.didTapSettings()
        })
        
        sheet.addAction(UIAlertAction(title: "Logout", style: .destructive) { action in
            self.didTapLogout()
        })
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(sheet, animated: true)
    }
    
//    MARK: - Helper Functions
    func configureUI() {
        authenticateButton.setDimensions(height: 300, width: 300)
        view.addSubview(authenticateButton)
        authenticateButton.centerX(inView: self.view)
        authenticateButton.centerY(inView: self.view)
        
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 0, paddingLeft: 25.5)
        actionButton.setDimensions(height: 30, width: 30)
    }
    
    
    func checkIfUserIsLoggedIn(){
        print("DEBUG:- CHECKING LOGIN STATUS")
        if FirebaseService.shared.getCurrentUID() == nil {
            print("DEBUG:- User not logged in!")
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }else{
            print("DEBUG:- User is logged in!  UID: \(String(describing: FirebaseService.shared.getCurrentUID()))")
            configureUI()
            
            guard let currentUID = FirebaseService.shared.getCurrentUID() else { return }
            
            FirebaseService.shared.fetchUserData(currentUID: currentUID) { user in
                self.user = user
            }
        }
    }
    
    func didTapSettings() {
        guard let user = self.user else { return }
        let controller = SettingsController(user: user)
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    func didTapLogout() {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (_) in
            FirebaseService.shared.signOut { error in
                if error != nil {
                    guard let error = error else { return }
                    print("Error occured while logging you out!: \(error.localizedDescription)")
                } else {
                    self.checkIfUserIsLoggedIn()
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension HomeController: TextToAudioWrapperDelegate {
    func messageDidReceive(_ string: String) {
        print("Received Message: \(string)")
        
        receivedMessage.text = string
    }
    
    func messageDidSend() {
        print("Message Did Send")
    }
}

//    MARK: - Delegate SettingsControllerDelegate
extension HomeController: SettingsControllerDelegate{
    func updateUser(_ controller: SettingsController) {
        self.user = controller.user
    }
}
