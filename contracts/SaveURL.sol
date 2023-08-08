// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract SaveURL {
    struct Folder {
        string[] uri;
        uint counter;

    }

    struct sharerStruct {
        address[] _to;
        string[] sharedURI;
    }
    address owner;
    uint256 public basicPrice;
    uint256 public premiumPrice = 0 ether;
    uint256 public masterPrice = 0 ether;

    uint256 constant BASIC_PLAN = 50;
    uint256 premiumPlanLimit;
    uint256 masterPlanLimit;

    mapping(address => mapping(string => Folder)) private folderItem;
    mapping(address => sharerStruct) private shared;
    //Item shared with a particular address
    mapping(address =>string[]) itemShared;
    mapping(address => bool) private accountStatus;
    mapping(address => string[]) private allFolderNames;

    // total spaces bought
    mapping(address => uint) private totalPurchsed;

    mapping(address => string[]) myURIs;

    // total spaces used
    mapping(address => uint) private totalUpload;
    modifier stat(address userAddr) {
        require(accountStatus[userAddr] == true, "non-user");
        require(msg.sender == userAddr, "not authorized");
        _;
    }
    // EVENT
    event spaceBought(address buyer);

constructor(uint _premiumPrice, uint _masterPrice, uint256 _premiumPlanlimit, uint _masterPlanlimit){
    premiumPrice = _premiumPrice;
    masterPrice = _masterPrice;
    premiumPlanLimit = _premiumPlanlimit;
    masterPlanLimit = _masterPlanlimit;
    owner = msg.sender;


}
    // Struct to save uri with counter: members(uri, counter)
    // 2d mapping address string struct
    // shared uri
    // mapping of address to array
    //  keep track of shared photos by sharer: mapping of sharer Address => struct(member: <Array of addresses>, <Array of URI strings>);

/**
* @dev create account
* it turns the mapping of account status to true
*/ 
  function CreateAccount() public {
        require(accountStatus[msg.sender] == false, 'already created');
        accountStatus[msg.sender] = true;
        totalPurchsed[msg.sender] = 50;
    }
    /**
* @dev Buy space
* Premium space
*address of the buyer

 */
    function buyPremiumSpace(address _buyer) public payable stat(_buyer) {
        require(msg.value >= premiumPrice, "INPUT_THE_CORRECT_PRICE");
        totalPurchsed[_buyer] += premiumPlanLimit;
        emit spaceBought(_buyer);
    }

    /**
* @dev Buy space
* Premium space
*address of the buyer

 */
    function buyMasterSpace(address _buyer) public payable stat(_buyer) {
        require(msg.value >= masterPrice, "INPUT_THE_CORRECT_PRICE");
        totalPurchsed[_buyer] += masterPlanLimit;
    }
/**
    @dev Set Prices
 */
    function setPrice(uint newPremiumPrice, uint newMasterPrice) external returns(bool){
        require(msg.sender == owner, 'not authorized');
        premiumPrice = newPremiumPrice;
        masterPrice = newMasterPrice;
        return true;
    }

    function setSpaceLimit(uint newPremiumPlan, uint newMasterPlan) external {
        premiumPlanLimit = newPremiumPlan;
        masterPlanLimit = newMasterPlan;
    }

    /**
        @dev Transfer Ownership
     */
    function TransferOwnership(address _newOwner) external returns(bool) {
        require(msg.sender == owner, 'not authorized');
        owner = _newOwner;
        return true;
    }


    /**
     * @dev Function to create folder
     */
    function CreateFolder(string memory _name) public {
        require(accountStatus[msg.sender] == true, "non-user");
        require(checkName(_name), "fail");
        folderItem[msg.sender][_name].uri = [""];
        folderItem[msg.sender][_name].counter = 0;
        allFolderNames[msg.sender].push(_name);
    }

    function checkName(string memory name_) internal view returns (bool) {
        string[] memory check = allFolderNames[msg.sender];
        for (uint i = 0; i <= check.length; i++) {
            require(sha256(bytes(name_)) != sha256(bytes(check[i])), "exist");
        }
        return true;
    }

  

    /**
     * @dev Function to save to Folder
     */
    function uploadURI(
        address _owner,
        string memory _folderName,
        string memory _uri
    ) public stat(_owner) {
        bool exist = nameExist(_owner, _folderName);

        require(totalUpload[_owner] <= totalPurchsed[_owner], "LIMIT_REACHED");

        require(exist, "FOLDER_NOT_CREATED");

        Folder storage saveFolder = folderItem[_owner][_folderName];
        myURIs[_owner].push(_uri);
        saveFolder.uri.push(_uri);
        saveFolder.counter += 1;
        totalUpload[_owner] += 1;
    }

    function nameExist(
        address _owner,
        string memory _name
    ) internal view returns (bool) {
        string[] memory check = allFolderNames[_owner];
        for (uint i = 0; i <= check.length; i++) {
            require(
                sha256(bytes(_name)) == sha256(bytes(check[i])),
                "FOLDER_DOES_NOT_EXIT"
            );
        }
        return true;
    }

    /**
    * @dev Function to return all folders
    
     */
    function getFolders(
        address _user
    ) public view stat(_user) returns (string[] memory) {
        return allFolderNames[_user];
    }

    /**
     * @dev Function to get folder details
     */
    function Getfolder(
        string memory _name,
        address _user
    ) public view stat(_user) returns (Folder memory folder) {
        folder = folderItem[msg.sender][_name];
    }

    /**
     * @dev Function to share uri
     */
    function shareURI(address _recipient, string memory _uri) external returns(bool){
       string[] memory uris = myURIs[msg.sender];    
        for(uint i = 0; i <= uris.length; i++ ){
            if((sha256(bytes(_uri))) == sha256(bytes(uris[i]))){

        itemShared[_recipient].push(_uri);
        shared[msg.sender].sharedURI.push(_uri);
        shared[msg.sender]._to.push(_recipient);
            }
            else{
                revert("URI_DOES_NOT_EXIST");
            }         
        }
        return true;
    }

    /**
    *function to return my saved uri
     */
     function returnMyURI(address _owner) view external stat(_owner) returns(string[] memory){
       return myURIs[_owner];
     }

    /**
    *@dev return uri i shared
     */
     function mySharedURI(address _owner) view external stat(_owner) returns(sharerStruct memory){
        return shared[_owner];
     }

    /**
    *function to return shared uri
     */
     function returnSharedURI(address _owner) view external stat(_owner) returns(string[] memory){
       return itemShared[_owner];
     }



    /**
     * @dev Function to delete uri
     */

     function deleteURI(address _owner, string memory _name, string memory _uri) external returns(bool){
       deleteFromFolder(_owner, _name, _uri);
       deleteFromMain(_owner, _uri);  
        return true;
     }

     function deleteFromFolder(address _owner, string memory _name, string memory _uri)internal {
        uint size = folderItem[_owner][_name].uri.length;
        string[] memory todelete = new string[](size);
        todelete = folderItem[_owner][_name].uri;
        
        for(uint j=0; j<= size; j++){
        if(sha256(bytes(_uri)) == sha256(bytes(todelete[j]))){
            todelete[j] = todelete[size - 1];
            folderItem[_owner][_name].uri = todelete;
            break;
        }
       }
         folderItem[_owner][_name].uri.pop();
     }
     function deleteFromMain(address _owner, string memory _uri)internal {
         uint size2 = myURIs[_owner].length; 
        string[] memory deleteuri = new string[](size2);
        deleteuri = myURIs[_owner];
        for(uint i =0; i<=size2; i++){
            if(sha256(bytes(_uri)) == sha256(bytes(deleteuri[i]))){
                deleteuri[i] = deleteuri[size2 - 1];
                myURIs[_owner] = deleteuri;
                break;
            }
        }
        myURIs[_owner].pop();
     }
}

  