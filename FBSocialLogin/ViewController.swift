import UIKit
import FBSDKLoginKit

class ViewController: UIViewController {
  
  let fbloginButton: FBSDKLoginButton = {
    let lb = FBSDKLoginButton()
    lb.backgroundColor = .blue
    lb.setTitle("Login With Facebook", for: .normal)
    lb.setTitleColor(.white, for: .normal)
    lb.translatesAutoresizingMaskIntoConstraints = false
    lb.readPermissions = ["email"]
    return lb
  }()
  
  lazy var fbCustom: UIButton = {
    let b = UIButton(type: .system)
    b.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
    b.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
    b.setTitle( FBSDKAccessToken.current() == nil ? "Custom Login With Facebook": "logout" , for: .normal)
    b.translatesAutoresizingMaskIntoConstraints = false
    b.addTarget(self, action: #selector(fbCustomClick), for: .touchUpInside)
    return b
  }()
  
  @objc func fbCustomClick(){

    if FBSDKAccessToken.current() == nil {
      fbCustomLogin()
    }else {
      fbCustomLogout()
    }

  }
  

  
  func fbCustomLogin(){
    FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
      if error != nil { print("custom login failed"); return }
      FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id,name,email"]).start(completionHandler: { (conn, res, error) in
        
        if error != nil { print("graph request failed"); return }
        print(res)
        self.fbCustom.setTitle("Logout", for: .normal)
      })
      if let r = result {
        print(r)
      }
    }
  }
  
  func fbCustomLogout(){
    FBSDKLoginManager().logOut()
    fbCustom.setTitle("Login With Facebook", for: .normal)
  }

  override func viewDidLoad() {
    view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    super.viewDidLoad()
    setupViews()
  }

  func setupViews(){
    view.addSubview(fbloginButton)
    view.addSubview(fbCustom)
    fbloginButton.delegate = self
    fbloginButtonSetup()
    fbCustomSetup()
  }
  
  func fbCustomSetup(){
    fbCustom.topAnchor.constraint(equalTo: fbloginButton.bottomAnchor, constant: 16).isActive = true
    fbCustom.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
    fbCustom.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
    fbCustom.heightAnchor.constraint(equalToConstant: 50).isActive = true
  }
  
  func fbloginButtonSetup(){
    fbloginButton.constraints.forEach { (l) in
      l.isActive = false
    }

    fbloginButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
    fbloginButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
    fbloginButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
    fbloginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
  }
  
}

extension ViewController: FBSDKLoginButtonDelegate  {
  

  func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    print("here")
    fbCustom.setTitle("Login With Facebook", for: .normal)
  }

  func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
    
    if result.isCancelled { return }
    if error != nil {
      print( "Error:: ", error)
      return
    }
    
    print("successful")
    print(result.declinedPermissions)
    
    fbCustom.setTitle("Logout", for: .normal)
    FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id,name,email"]).start { (conn, res, error) in
      if error != nil {
        print("graph request failed")
        return
      }
      print(res ?? "")
    }
  }
}

