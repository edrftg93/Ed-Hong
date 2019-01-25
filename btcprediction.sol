pragma solidity 0.4.25;

    contract MakePrediction {

        address watch_addr = 0x0CBFC6ee8E313522651463b083EecfC6be746979;

        function predict() public {
            
            Prediction prediction = Prediction(watch_addr);
            
            // fill your blocktestUserId and your prediction values below
            string memory _blockTESTUserId = "";
            string memory _value = "";
            
            // calling the main contract function to save the value
            prediction.predict(_blockTESTUserId, _value);
        }
    }

    contract Prediction {
        
        address private owner;
        
        mapping(bytes32 => string) private predictionMap;
        // set as public and can be viewed by anyone
        int public uniquePredictions = 0;
        int public predictions = 0;
        
        constructor() public {
            owner = msg.sender;
        }
        
        event PredictionEvent(string blockTESTUserId, string value, int predictions, int uniquePredictions);
        
        // taking a value as string to make it easy to store the predictions
        function predict(string memory blockTESTUserId, string memory val) public {
            // making sure only owner can post the predictions
            require (tx.origin == owner, "Only owner can post predictions!");
            
            // making sure this is user's first prediction (unique)
            if (bytes(predictionMap[(keccak256(blockTESTUserId))]).length == 0)
                uniquePredictions += 1;
            predictions += 1;
            predictionMap[keccak256(blockTESTUserId)] = val;
            
            // emitting event
            emit PredictionEvent(blockTESTUserId, val, predictions, uniquePredictions);
        }
        
        // access this function to get your prediction
        function getPrediction(string memory blockTESTUserId) public view returns (string memory) {
            return predictionMap[keccak256(blockTESTUserId)];
        }
    }
