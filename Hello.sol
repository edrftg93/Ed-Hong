/*  
        author - Prateek Adhikaree
        date - 9/8/18
        5 functions to ensure Scenario1 - Handshake
    */ 
    
    pragma solidity ^0.4.21;
    contract Scenario1_Handshake { 
        struct task {                    
            bool isPresent;                         
            bool isConfirmed;                         
            bool isAwarded;                        
            uint16 taskId;                         
            address owner;                         
            uint256 amount;                        
            address evaluator;                        
            bytes32 result;                         
        } 
                            
        /* Variables */ 
        address public contractAddress;                
        mapping(uint16 => task) public tasks;
                            
        /* Events */                         
        event NewTask(uint16 taskId);                         
        event TaskPicked(uint16 taskId, address evaluator);            
        event AwardedToken(uint16 taskId, uint amount); 
                            
        constructor() public {
            contractAddress = msg.sender;                       
        } 
                            
        /*                          
            Owner posts the task and sends an amount that he is prepared to pay     
            Task is saved to the contract                        
            The amount is also deducted here. Transferred to the contract's address
        */                         
        function postTask(uint16 _taskId) public payable {          
            // ensuring the taskId param is sent             
            require(_taskId != 0, "TaskID is required");           
            // ensuring the task does not exist already          
            require(!tasks[_taskId].isPresent, "Task already exists");     
            task memory myTask;                         
            myTask.taskId = _taskId;                         
            myTask.owner = msg.sender;                        
            myTask.amount = msg.value;                         
            myTask.isAwarded = false;              
            myTask.isConfirmed = false;                         
            myTask.isPresent = true; 
                            
            tasks[_taskId] = myTask; 
                            
            // invoking event                         
            emit NewTask(_taskId); 
                            
            // take the amount from the owner's account and add to contract address
            // added at the end to avoid re-entrancy vulnerability 
            // max 2300 gas limit 
            contractAddress.transfer(msg.value);  
        } 

        /* 
            Evaluator picks task to give its result     
        */ 
        function pickTask(uint16 _taskId) public { 
            // ensuring the taskId param is sent                
            require(_taskId != 0, "TaskID is required");                
            // ensuring the task is valid                
            require(tasks[_taskId].isPresent, "Invalid task selected"); 
    
            tasks[_taskId].evaluator = msg.sender; 
        
            // invoking event 
            emit TaskPicked(_taskId, msg.sender); 
        } 

        /*  
            Evaluator submits the result 
        */  
        function submitResult(uint16 _taskId, bytes32 _result) public {
            // ensuring the taskId and result param are sent       
            require(_taskId != 0 && _result != 0, "TaskID & ResultID are required");
            // ensuring that the task is valid        
            require(tasks[_taskId].isPresent, "Invalid taskId");          
            // ensuring that the correct account is submitting the result       
            require(tasks[_taskId].evaluator == msg.sender, "Unauthorized user");
        
            tasks[_taskId].result = _result; 
        } 

        /*  
            Owner validates the result    
        */      
        function confirmResult(uint16 _taskId) public {              
            // ensuring the taskId param is sent 
            require(_taskId != 0, "TaskID is required"); 
            // ensuring that the task is valid  
            require(tasks[_taskId].isPresent, "Invalid taskId"); 
            // ensuring the valid owner is accessing this function 
            require(tasks[_taskId].owner == msg.sender, "Unauthorized user"); 

            tasks[_taskId].isConfirmed = true;  
        } 
    
        /*  
            Contract invokes this method to award token to the evaluator 
            AI team is awarded the amount 
        */ 
        function awardToken(uint16 _taskId) public payable { 
            // ensuring the taskId param is sent 
            require(_taskId != 0, "TaskID is required"); 
            // ensuring that contract is invoking this function 
            require(msg.sender == contractAddress, "Unauthorized user"); 
            // ensuring that the task is valid 
            require(tasks[_taskId].isPresent, "Invalid taskId"); 
            // ensuring that the contract is confirmed 
            require(tasks[_taskId].isConfirmed, "Result not confirmed"); 
            // verifying that the token is not awarded 
            require(!tasks[_taskId].isAwarded, "Token already awarded"); 

            // invoking event 
            emit AwardedToken(_taskId, tasks[_taskId].amount); 
    
            tasks[_taskId].isAwarded = true; 

            // awarding token; added at the end to avoid re-entrancy vulnerability 
            // max 2300 gas limit 
            tasks[_taskId].evaluator.transfer(msg.value); 
        } 
    } 
