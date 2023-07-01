// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Ballot {
    struct Voter {
        uint score;
        bool isAdmin;
    }

    struct Vote {
        address voter;
        uint voteValue;
    }

    struct Proposal {
        string title;
        string description;
        bool isOpen;
        Vote[] votes;
        mapping(address => bool) hasVoted;
    }

    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    constructor() {
        voters[msg.sender].isAdmin = true;
    }

    function setAdmin(address targetUser) public {
        require(voters[msg.sender].isAdmin, "Only admin can set admin");
        voters[targetUser].isAdmin = true;
    }

    function createProposal(
        string memory title,
        string memory description
    ) public {
        require(voters[msg.sender].isAdmin, "Only admin can create proposal");
        Proposal storage proposal = proposals.push();
        proposal.title = title;
        proposal.description = description;
        proposal.isOpen = true;
    }

    function voteForProposal(uint proposalIndex, uint voteValue) public {
        require(
            proposalIndex >= 0 && proposalIndex < proposals.length,
            "Invalid proposal index"
        );
        Proposal storage proposal = proposals[proposalIndex];
        require(proposal.isOpen, "Proposal is closed");
        require(
            !proposal.hasVoted[msg.sender],
            "You have already voted for this proposal"
        );
        proposal.votes.push(Vote(msg.sender, voteValue));
        proposal.hasVoted[msg.sender] = true;
    }

    function closeProposal(uint proposalIndex, uint correctValue) public {
        require(voters[msg.sender].isAdmin, "Only admin can close proposal");
        require(
            proposalIndex >= 0 && proposalIndex < proposals.length,
            "Invalid proposal index"
        );
        Proposal storage proposal = proposals[proposalIndex];
        require(proposal.isOpen, "Proposal is already closed");
        proposal.isOpen = false;
        for (uint i = 0; i < proposal.votes.length; i++) {
            Vote storage vote = proposal.votes[i];
            if (vote.voteValue == correctValue) {
                voters[vote.voter].score++;
            }
        }
    }
}
