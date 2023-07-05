// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract socialMedia{
    
    struct userData{
        uint registrationNumber;
        string userName;
        string profilePic;
        address userAddress;
    }

    userData[] members;

    struct posts{
        uint registrationNumber;
        uint postNumber;
        uint likes;
        address[] likedAddress;
        string imageLink;
        string[] comments;
        uint allPostIndex;
    }

    posts[] totalPosts;

    mapping(uint=>posts[]) Posts;

    mapping(uint=>string[]) tempFriendRequestArray;

    mapping(uint=>string[]) friendsArray;

    function getRegistrationNumber() private view returns(uint){
        for(uint i = 0;i<members.length;i++){
            if(msg.sender==members[i].userAddress){
                return i+1;
            }
        }
        return 0;
    }

    function checkUserNameAvailable(string memory _userName) internal view returns (bool){
        for(uint i = 0;i<members.length;i++){
            if(keccak256(abi.encodePacked(_userName )) == keccak256(abi.encodePacked(members[i].userName))){
                return false;
            }
        }
        return true;
    }

    function getRegistrationNumberFromAllPostIndex(uint index) internal view returns(uint){
        return totalPosts[index].registrationNumber;
    }

    function getPostIndexfromAllPostIndex(uint index) internal view returns(uint){
        return totalPosts[index].postNumber;
    }

    function checkAlreadyLiked(uint allPostIndex) internal view returns(bool) {
        uint postOwnerRegNum = getRegistrationNumberFromAllPostIndex(allPostIndex);
        uint _postNumber = getPostIndexfromAllPostIndex(allPostIndex);
        for(uint i = 0 ; i<Posts[postOwnerRegNum][_postNumber].likedAddress.length;i++){
            if(Posts[postOwnerRegNum][_postNumber].likedAddress[i]==msg.sender){
                return true;
            }
        }
        return false;
    }

    function checkRegistered() internal view returns(bool){
        for(uint i = 0;i<members.length;i++){
            if(msg.sender==members[i].userAddress){
                return true;
            }
        }
        return false;
    }

    function getUserName() public view returns(string memory){
        for(uint i = 0;i<members.length;i++){
            if(msg.sender==members[i].userAddress){
                return members[i].userName;
            }
        }
        return "";
    }

    function checkFriendRequestAlreadySent(uint friendRegistrationNumber) internal view returns(bool){
        string memory _userName = getUserName();
        for(uint i = 0;i<tempFriendRequestArray[friendRegistrationNumber].length;i++){
            if(keccak256(abi.encodePacked(tempFriendRequestArray[friendRegistrationNumber][i])) == keccak256(abi.encodePacked(_userName))){
                return true;
            }
        }
        return false;
    }

    function findUser(string memory _userName) public view returns(uint){
        for(uint i = 0;i<members.length;i++){
            if(keccak256(abi.encodePacked(_userName )) == keccak256(abi.encodePacked(members[i].userName))){
                return i+1;
            }
        }
        return 0;
    }

    function registerUser(string memory _userName,string memory _profilePic) public {
        require(checkUserNameAvailable(_userName),"Username not available");
        require(!checkRegistered(),"Address already used to register");
        members.push(userData({
            userName : _userName,
            userAddress : msg.sender,
            profilePic : _profilePic,
            registrationNumber:members.length+1
            })
        );
    }

    function changeProfilePicture(string memory _profilePic) public {
        uint _registrationNumber = getRegistrationNumber();
        require(_registrationNumber>0,"Not registered");
        members[_registrationNumber].profilePic = _profilePic;
    }

    function changeUserName(string memory _userName) public {
        require(checkUserNameAvailable(_userName),"Username not available");
        uint _registrationNumber = getRegistrationNumber();
        require(_registrationNumber>0,"Not registered");
        members[_registrationNumber].userName = _userName;
    }

    function sendFriendRequest(string memory _userName) public {
        uint friendRegistrationNumber = findUser(_userName);
        require(checkRegistered(),"You are not registred");
        require(!checkFriendRequestAlreadySent(friendRegistrationNumber),"Already sent");
        tempFriendRequestArray[friendRegistrationNumber].push(getUserName());
    }

    function seeFriendRequests() public view returns(string[] memory){
        return tempFriendRequestArray[getRegistrationNumber()];
    }

function acceptFriendRequests(uint index) public {
        uint userRegNum = getRegistrationNumber();
        friendsArray[userRegNum].push(tempFriendRequestArray[userRegNum][index]);
        string memory temp = tempFriendRequestArray[userRegNum][index];
        uint friendRegNum = findUser(temp);
        friendsArray[friendRegNum].push(getUserNameFromRegistrationNumber(userRegNum));
        tempFriendRequestArray[userRegNum][index] = "accepted";
    }

    function deleteFriendrequest(uint index) public {
        uint userRegNum = getRegistrationNumber();
        tempFriendRequestArray[userRegNum][index] = "deleted";
    }

    function seeMyfriends() public view returns(string[] memory){
        return friendsArray[getRegistrationNumber()];
    }

    string[] tempCommentArray;
    address[] tempLikedAddressesArray;


    function doAPost(string memory _imageLink) public {
        uint regNum = getRegistrationNumber();
        posts memory post = posts({
            likes : 0,
            imageLink : _imageLink,
            postNumber : Posts[regNum].length,
            likedAddress : tempLikedAddressesArray,
            allPostIndex : totalPosts.length,
            comments : tempCommentArray,
            registrationNumber : regNum});

        Posts[regNum].push(post);
        totalPosts.push(post);
    }


    function doALike(uint allPostIndex) public {
        require(!checkAlreadyLiked(allPostIndex),"You have already liked");
        uint postOwnerRegNum = getRegistrationNumberFromAllPostIndex(allPostIndex);
        uint _postNumber = getPostIndexfromAllPostIndex(allPostIndex);
        Posts[postOwnerRegNum][_postNumber].likes = Posts[postOwnerRegNum][_postNumber].likes+1;
        Posts[postOwnerRegNum][_postNumber].likedAddress.push(msg.sender);
        totalPosts[Posts[postOwnerRegNum][_postNumber].allPostIndex] = Posts[postOwnerRegNum][_postNumber];
    }

    function seeMyPosts() public view returns(posts[] memory){
        return Posts[getRegistrationNumber()];
    }

    function deleteAPost(uint allPostIndex) public {
        uint myRegNum = getRegistrationNumber();
        uint _postNumber = getPostIndexfromAllPostIndex(allPostIndex);
        delete Posts[myRegNum][_postNumber];
        totalPosts[Posts[myRegNum][_postNumber].allPostIndex] = Posts[myRegNum][_postNumber];
    }

    function seeAllPosts() public view returns(posts[] memory){
        return totalPosts;
    }

    // function doAComent(string memory comment , uint allPostIndex) public {
    //     uint postOwnerRegNum = getRegistrationNumberFromAllPostIndex(allPostIndex);
    //     uint _postNumber = getPostIndexfromAllPostIndex(allPostIndex);
    //     Posts[postOwnerRegNum][_postNumber].comments.push(comment);
    //     totalPosts[Posts[postOwnerRegNum][_postNumber].allPostIndex] = Posts[postOwnerRegNum][_postNumber];
    // }

    function seeCommentOnPost(uint allPostIndex) public view returns(string[] memory){
         uint postOwnerRegNum = getRegistrationNumberFromAllPostIndex(allPostIndex);
        uint _postNumber = getPostIndexfromAllPostIndex(allPostIndex);
        return Posts[postOwnerRegNum][_postNumber].comments;
    }

    function seeLikesOnPost(uint allPostIndex)public view returns (uint){
        uint postOwnerRegNum = getRegistrationNumberFromAllPostIndex(allPostIndex);
        uint _postNumber = getPostIndexfromAllPostIndex(allPostIndex);
        return Posts[postOwnerRegNum][_postNumber].likes;
    }

    function seeTotalFriends() public view returns(uint){
        return friendsArray[getRegistrationNumber()].length;
    }

    function seeSpecificFriendsPost(uint friendsRegNum) public view returns(posts[] memory){
        return Posts[friendsRegNum];
    }
    function getOthersUserStruct(uint registration) public view returns(userData memory){
        return members[registration-1];
    }
    function getUserNameFromRegistrationNumber(uint regNum) public view returns(string memory){
        for(uint i = 0;i<members.length;i++){
            if(regNum == members[i].registrationNumber){
                return members[i].userName;
            }
        }
        return "NotFound";
    }
    function checkRegisteredReturnRegNum() public view returns(uint){
        for(uint i = 0;i<members.length;i++){
            if(msg.sender==members[i].userAddress){
                return members[i].registrationNumber;
            }
        }
        return 0;
    }
    function allUsers() public view returns(userData[] memory){
        return members;
    }
    function totalNumberOfPosts() public view returns(uint){
        return totalPosts.length;
    }
    // function doAComent(string memory comment , uint allPostIndex) public {
    //     uint postOwnerRegNum = getRegistrationNumberFromAllPostIndex(allPostIndex);
    //     uint _postNumber = getPostIndexfromAllPostIndex(allPostIndex);
    //     comment = string.concat(" : ",comment);
    //     string memory temp = comment;
    //     string memory temp2 = getUserName();
    //     comment = string.concat(temp2,temp);
    //     Posts[postOwnerRegNum][_postNumber].comments.push(comment);
    //     totalPosts[Posts[postOwnerRegNum][_postNumber].allPostIndex] = Posts[postOwnerRegNum][_postNumber];
    // }
}