// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Decentralized Voting System
 * @dev A transparent and secure voting system on the blockchain
 * @author Your Name
 */
contract Project {
    
    // Struct to represent a candidate
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
        bool exists;
    }
    
    // Struct to represent a voter
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedCandidateId;
    }
    
    // State variables
    address public owner;
    string public electionName;
    bool public votingActive;
    uint256 public candidateCount;
    uint256 public totalVotes;
    
    // Mappings
    mapping(uint256 => Candidate) public candidates;
    mapping(address => Voter) public voters;
    
    // Events
    event CandidateAdded(uint256 indexed candidateId, string name);
    event VoterRegistered(address indexed voter);
    event VoteCast(address indexed voter, uint256 indexed candidateId);
    event VotingStatusChanged(bool active);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier onlyRegisteredVoter() {
        require(voters[msg.sender].isRegistered, "You must be registered to vote");
        _;
    }
    
    modifier votingIsActive() {
        require(votingActive, "Voting is not currently active");
        _;
    }
    
    // Constructor
    constructor(string memory _electionName) {
        owner = msg.sender;
        electionName = _electionName;
        votingActive = false;
        candidateCount = 0;
        totalVotes = 0;
    }
    
    /**
     * @dev Core Function 1: Add a new candidate to the election
     * @param _name The name of the candidate
     */
    function addCandidate(string memory _name) public onlyOwner {
        require(bytes(_name).length > 0, "Candidate name cannot be empty");
        require(!votingActive, "Cannot add candidates while voting is active");
        
        candidateCount++;
        candidates[candidateCount] = Candidate({
            id: candidateCount,
            name: _name,
            voteCount: 0,
            exists: true
        });
        
        emit CandidateAdded(candidateCount, _name);
    }
    
    /**
     * @dev Core Function 2: Register a voter
     * @param _voter The address of the voter to register
     */
    function registerVoter(address _voter) public onlyOwner {
        require(_voter != address(0), "Invalid voter address");
        require(!voters[_voter].isRegistered, "Voter is already registered");
        
        voters[_voter] = Voter({
            isRegistered: true,
            hasVoted: false,
            votedCandidateId: 0
        });
        
        emit VoterRegistered(_voter);
    }
    
    /**
     * @dev Core Function 3: Cast a vote for a candidate
     * @param _candidateId The ID of the candidate to vote for
     */
    function vote(uint256 _candidateId) public onlyRegisteredVoter votingIsActive {
        require(!voters[msg.sender].hasVoted, "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        require(candidates[_candidateId].exists, "Candidate does not exist");
        
        // Record the vote
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        
        // Update candidate vote count
        candidates[_candidateId].voteCount++;
        totalVotes++;
        
        emit VoteCast(msg.sender, _candidateId);
    }
    
    // Additional utility functions
    
    /**
     * @dev Toggle voting status (start/stop voting)
     */
    function toggleVoting() public onlyOwner {
        require(candidateCount > 0, "Must have at least one candidate before starting voting");
        votingActive = !votingActive;
        emit VotingStatusChanged(votingActive);
    }
    
    /**
     * @dev Get candidate details
     * @param _candidateId The ID of the candidate
     * @return id, name, voteCount of the candidate
     */
    function getCandidate(uint256 _candidateId) public view returns (uint256, string memory, uint256) {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
    
    /**
     * @dev Get election results
     * @return Array of candidate names and their vote counts
     */
    function getResults() public view returns (string[] memory, uint256[] memory) {
        string[] memory names = new string[](candidateCount);
        uint256[] memory votes = new uint256[](candidateCount);
        
        for (uint256 i = 1; i <= candidateCount; i++) {
            names[i-1] = candidates[i].name;
            votes[i-1] = candidates[i].voteCount;
        }
        
        return (names, votes);
    }
    
    /**
     * @dev Get the winning candidate
     * @return name and vote count of the winner
     */
    function getWinner() public view returns (string memory, uint256) {
        require(candidateCount > 0, "No candidates available");
        
        uint256 winningVoteCount = 0;
        uint256 winningCandidateId = 0;
        
        for (uint256 i = 1; i <= candidateCount; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateId = i;
            }
        }
        
        if (winningCandidateId == 0) {
            return ("No winner yet", 0);
        }
        
        return (candidates[winningCandidateId].name, winningVoteCount);
    }
}
