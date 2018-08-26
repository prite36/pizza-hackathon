pragma solidity ^0.4.24;
import "./BasicStringUtil.sol";
contract SmartAuction{
    using BasicStringUtils for string;
    string[] private projects;
    string[] private companys;
    
    mapping(address => Company) public CompanyInfo;
    mapping(string => Project) private projectsInfo;
    
    enum CompanyStatus {
        wating,
        rejected,
        approved
    }
    
    struct Bidding{
        uint price;
        uint timestamp;
    }
    struct Company{
        bool created;
        string name;
        uint id;
    }
   struct Project{
       bool created;
       string description;
       uint starttimeauction;
       uint stoptimeauction;
       uint closetimeregister;
       uint budget;
       uint winprice;
       address winname;
       address[] company;
       address[] bids;
       uint id;
       uint totalCompany;
       //mapping(address => CompanyStatus) companystatus;
       
       mapping(address => uint) companyIdMap;
       mapping(address => bool) didBid;
       
       mapping(address => Bidding[]) bidsList;
   }
   
   mapping (address => mapping(string => CompanyStatus)) companyProjectStatus;
   
   function getCompanyStatusByProjectID(address _company, string _nameProject) public view returns (CompanyStatus) {
       return companyProjectStatus[_company][_nameProject];
       // com[][] = CompanyStatus.wating
   }
    
    function register(address _user,string _name) public{
       require(_name.isNotEmpty());
       require(CompanyInfo[_user].created==false);
       companys.push(_name);
       CompanyInfo[_user] = Company(true,_name,companys.length-1);
    }
    
    function getCompanyName(address _company) public view returns(string _name){
      
        
        require(
            _company != address(0),
            "'_company' contains an invalid address."
        );

        require(
            __isCompany(_company),
            "Cannot find the specified company."
        );

        return CompanyInfo[_company].name;
    }
     function getCompanyArrayLength() external view returns (uint _length) {
        return companys.length;
    }
    function getProjectsName(uint _projectIndex) external view returns(string _name){
        _name=projects[_projectIndex];
        return;
    }
     function getTotalProjects() external view returns (uint _total) {
        _total = 0;
        for (uint i = 0; i < projects.length; i++) {
            // Team might not be removed before
            if (projects[i].isNotEmpty() && projectsInfo[projects[i]].created) {
                _total++;
            }
        }
    }
    function getProjectInfo(string _nameProject) external view returns (
        string description,
       uint starttimeauction,
       uint stoptimeauction,
       uint closetimeregister,
       uint budget,
       address[] company,
       address winname,
       uint winprice) {
           
        assert(_nameProject.isNotEmpty());
        description=projectsInfo[_nameProject].description;
        starttimeauction=projectsInfo[_nameProject].starttimeauction;
        stoptimeauction=projectsInfo[_nameProject].stoptimeauction;
        closetimeregister=projectsInfo[_nameProject].closetimeregister;
        budget=projectsInfo[_nameProject].budget;
        company=projectsInfo[_nameProject].company;
        winname=projectsInfo[_nameProject].winname;
        winprice=projectsInfo[_nameProject].winprice;
        return;
    }
    

     function isCompany(address _user) external view returns (bool _bPlayer) {
        return __isCompany(_user);
    }

    
    function __isCompany(address _user) internal view returns (bool _bPlayer) {
        require(
            _user != address(0),
            "'_user' contains an invalid address."
        );

        return CompanyInfo[_user].created;
    }
    
    
    function getCompanyInProjectAtIndex(string _nameProject, uint _CompanyIndex) 
        external view
        returns (
            bool _endOfList, 
            address _company
        )
    {
        require(
            _nameProject.isNotEmpty()
        );

        require(
            projectsInfo[_nameProject].created
        );

        if (_CompanyIndex >= projectsInfo[_nameProject].company.length) {
            _endOfList = true;
            _company = address(0);
            return;
        }

        _endOfList = false;
        _company = projectsInfo[_nameProject].company[_CompanyIndex];
    }

    
    

    
   
   function createProject(string _name, string _description, uint _starttimeauction, uint _stoptimeauction, uint _closetimeregister, uint _budget) public{
       require(_name.isNotEmpty());
       require(projectsInfo[_name].created==false);
       projects.push(_name);
       projectsInfo[_name] = Project(true,_description,_starttimeauction,_stoptimeauction,_closetimeregister,_budget,_budget,address(0),new address[](0),new address[](0),projects.length-1,0);
   }
   
   function registerCompanyToProject(address _company, string _nameProject) external{
       require(_company != address(0),'Please Login!');
       require(_nameProject.isNotEmpty(),'Project name should not be empty!');
       require(projectsInfo[_nameProject].created==true,'No project exists!');
       require(now<projectsInfo[_nameProject].closetimeregister,'Register is closed!');
       projectsInfo[_nameProject].company.push(_company);
       projectsInfo[_nameProject].totalCompany++;
       projectsInfo[_nameProject].companyIdMap[_company] = projectsInfo[_nameProject].company.length -1;
       companyProjectStatus[_company][_nameProject]=CompanyStatus.wating;
       
   }
   
   function changeStatusCompany(address _company, string _nameProject, uint _status) external {
        require(_company != address(0));
        require(_nameProject.isNotEmpty());
        require(projectsInfo[_nameProject].created==true);
        require(_status < 3,
            "Error: status wrong"
        );
        companyProjectStatus[_company][_nameProject] = CompanyStatus(_status);    
    }
    
    function goBid (address _company,string _nameProject, uint _price) external {
       require(_company != address(0),'Please Login!');
       require(projectsInfo[_nameProject].created==true,'No project exists!');
       require(_price>0 && _price<=projectsInfo[_nameProject].budget,'Price is not valid!');
       require(companyProjectStatus[_company][_nameProject]==CompanyStatus.approved,'Not approved yet!');
       require((now>projectsInfo[_nameProject].starttimeauction)&&(now<projectsInfo[_nameProject].stoptimeauction),"Can't start bidding yet");
     
      if(!projectsInfo[_nameProject].didBid[_company]){ 
       projectsInfo[_nameProject].bids.push(_company);
      }
      
       projectsInfo[_nameProject].bidsList[_company].push(Bidding(_price, now));
       if(_price<projectsInfo[_nameProject].winprice){
            projectsInfo[_nameProject].winprice=_price;
            projectsInfo[_nameProject].winname=_company;
       }
   }
   
   /*function consensus(string _nameProject) external view returns(string _name){
       require(projectsInfo[_nameProject].created==true,'No project exists!');
       require(projectsInfo[_nameProject].bids.length>0);
       uint temp_price = projectsInfo[_nameProject].budget;
       for(uint i; i<projectsInfo[_nameProject].bids.length;i++){
           for(uint j; j<projectsInfo[_nameProject].bidsList[projectsInfo[_nameProject].bids[i]].length;j++){
               if(temp_price>projectsInfo[_nameProject].bidsList[projectsInfo[_nameProject].bids[i]][j].price){
                   temp_price = projectsInfo[_nameProject].bidsList[projectsInfo[_nameProject].bids[i]][j].price;
                   _name = getCompanyName(projectsInfo[_nameProject].bids[i]);
               }
           }
       }
   }*/
    function showBidByIndex (address _company, string _nameProject, uint _index) external view returns (uint price, uint timestamp) {
        price = projectsInfo[_nameProject].bidsList[_company][_index].price;
        timestamp = projectsInfo[_nameProject].bidsList[_company][_index].timestamp;
        return;
   } 
    function getProjectCompanyBidLength(string _nameProject) external view returns (uint _length) {
        return projectsInfo[_nameProject].bids.length;
    }
    function getProjectBidLength(address _company,string _nameProject) external view returns (uint _length) {
        return projectsInfo[_nameProject].bidsList[_company].length;
    }
   
   
    
}