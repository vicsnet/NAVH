// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract SaveURL{

    struct Folder {
        string[] uri;
        uint counter; 
    }

    struct sharerStruct {
        address[] _to;
        string[] sharedURI;
    }

    struct purchaseLimit{
        uint folderItemlimit;
        uint folderLimit;
    }


// total spaces bought
// total spaces used   ech i can't stop laughing
    
   mapping(address => mapping(string => Folder)) private folderItem;
   mapping(address => sharerStruct) private shared;
   mapping(address => bool) private accountStatus;
   mapping(address => string[]) private allFolderNames; 
   mapping (address => purchaseLimit) accountLimit;

mapping(address => uint) private totalPurchsed;
mapping (address => uint) private totalUpload;
    modifier stat(address userAddr) {
         require(accountStatus[userAddr] == true, 'non-user');
        require(msg.sender == userAddr, 'not authorized');
        _;
    }

    // Struct to save uri with counter: members(uri, counter)
    // 2d mapping address string struct 
    // shared uri 
    // mapping of address to array
    //  keep track of shared photos by sharer: mapping of sharer Address => struct(member: <Array of addresses>, <Array of URI strings>);




    /**
    * @dev Function to create folder
     */
    function CreateFolder(string memory _name) public {
        require(accountStatus[msg.sender] == true, 'non-user');
        require(checkName(_name), 'fail');      
        folderItem[msg.sender][_name].uri = [''];
        folderItem[msg.sender][_name].counter = 0;
        allFolderNames[msg.sender].push(_name);
    }

    function checkName(string memory name_) internal view returns (bool){
        string[] memory check = allFolderNames[msg.sender];
        for(uint i=0; i <= check.length; i++){
            require(sha256(bytes(name_)) != sha256(bytes(check[i])), 'exist');
        }
        return true;
    }

    function CreateAccount() public {
        accountStatus[msg.sender] = true;
        accountLimit[msg.sender]
        
    }
    /**
    * @dev Function to save to Folder
     */
     function uploadURI(address _owner, string memory _folderName, string memory _uri) public stat(_owner) {
        
        bool exist = nameExist(_owner, _folderName);
      
        require(exist, "FOLDER_NOT_CREATED");
        
        Folder storage saveFolder = folderItem[_owner][_folderName];
        saveFolder.uri.push(_uri);
        saveFolder.counter += 1;

        
     }

     function nameExist(address _owner, string memory _name) internal view returns(bool){
        string[] memory check = allFolderNames[_owner];
        for(uint i=0; i<= check.length; i++){
            require(sha256(bytes(_name) ) == sha256(bytes(check[i])),  "FOLDER_DOES_NOT_EXIT");
        }
        return true;
     }
    
    /**
    * @dev Function to return all folders
    
     */
     function getFolders (address _user) public view stat(_user) returns (string[] memory) {
        return allFolderNames[_user];
     }

    /**
    * @dev Function to get folder details
     */
     function Getfolder(string memory _name, address _user) public view stat(_user) returns (Folder memory folder){
        folder = folderItem[msg.sender][_name];
     }

    /**
    * @dev Function to share uri
     */
    // function shareURI() 

    /**
    * @dev Function to delete uri
     */






}