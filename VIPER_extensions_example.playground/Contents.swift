import UIKit
import XCTest

// =========================================== EXAMPLE ===========================================

// Edit Profile Module protocols

protocol EditProfileViewInterface: class {

    func nameTextFieldContent() -> String

}
protocol EditProfilePresenterInterface {

    var firstName: String? { get }
    func didChangeNameText()

}
protocol EditProfileInteractorInterface: InteractorUserInterface, InteractorEditUserInterface {}
protocol EditProfileInteractorDelegate: class {}
protocol EditProfileDataManagerInterface: DataManagerUserInterface {}

// Edit Profile Module classes

class EditProfileWireframe {}

class EditProfileViewController: UIViewController, EditProfileViewInterface {
    
    var presenter: EditProfilePresenterInterface!
    
    func nameTextFieldContent() -> String {
        return "text from textfield"
    }
    
}

class EditProfilePresenter: EditProfilePresenterInterface, EditProfileInteractorDelegate {
    
    var wireframe: EditProfileWireframe!
    var interactor: EditProfileInteractor!
    weak var viewInterface: EditProfileViewInterface?
    
    var firstName: String? {
        return interactor.userInfo?.firstName
    }
    
    func didChangeNameText() {
        if let text = viewInterface?.nameTextFieldContent() {
            interactor.updateUser(firstName: text)
        }
    }
    
}

class EditProfileInteractor: EditProfileInteractorInterface {
    
    var dataManager: EditProfileDataManagerInterface!
    weak var delegate: EditProfileInteractorDelegate?
    
    var userDataManager: DataManagerUserInterface {
        return dataManager
    }
    
}

class EditProfileDataManager: EditProfileDataManagerInterface {}

// User Interface

protocol DataManagerUserInterface {
    
    var userSessionManager: UserSessionManager { get }
    
}

protocol InteractorUserInterface {
    
    var userDataManager: DataManagerUserInterface { get }
    var userInfo: UserInfo? { get }
    
}

extension DataManagerUserInterface {
    
    var userSessionManager: UserSessionManager {
        return UserSessionManager.shared
    }
    
}

extension InteractorUserInterface {
    
    var userInfo: UserInfo? {
        guard let user = userDataManager.userSessionManager.currentUser else { return nil }
        return UserInfo(user: user)
    }
    
}

// Edit User Interface

protocol InteractorEditUserInterface {
    
    var userDataManager: DataManagerUserInterface { get }
    func updateUser(firstName: String)
    
}

extension InteractorEditUserInterface {
    
    func updateUser(firstName: String) {
        guard var user = userDataManager.userSessionManager.currentUser else { return }
        user.firstName = firstName
        userDataManager.userSessionManager.updateCurrentUser(user)
    }
    
}

// Helpers

struct UserInfo {
    
    let firstName: String
    
    init(user: User) {
        self.firstName = user.firstName
    }
    
}

struct User {
    
    var firstName: String
    
}

class UserSessionManager {
    
    static let shared = UserSessionManager()
    
    private lazy var fakeUser = {
        return User(firstName: "User")
    }()
    
    var currentUser: User? {
        return fakeUser
    }
    
    func updateCurrentUser(_ user: User) {
        self.fakeUser = user
    }
    
}

// =========================================== TESTS ===========================================

// Stubs


class StubUserSessionManager: UserSessionManager {
    
    var stubUser: User?
    
    override var currentUser: User? {
        return stubUser
    }
    
}

class StubUserDataManager: DataManagerUserInterface {
    
    lazy var stubUserSessionManager = {
        return StubUserSessionManager()
    }()
    
    var userSessionManager: UserSessionManager {
        return stubUserSessionManager
    }
    
}

// Tests

class InteractorUserInterfaceTests: XCTestCase {
    
    class TestInteractor: InteractorUserInterface {
        
        lazy var stubUserDataManager: StubUserDataManager = {
            return StubUserDataManager()
        }()
        
        var userDataManager: DataManagerUserInterface {
            return stubUserDataManager
        }
        
    }
    
    var interactor: TestInteractor!
    
    override func setUp() {
        interactor = TestInteractor()
    }
    
    func testUserInfoHasCorrectFirstName() {
        interactor.stubUserDataManager.stubUserSessionManager.stubUser = User(firstName: "testName")
        XCTAssertEqual(interactor.userInfo?.firstName, "testName")
    }
    
}

let testCase = InteractorUserInterfaceTests.defaultTestSuite()
testCase.run()
