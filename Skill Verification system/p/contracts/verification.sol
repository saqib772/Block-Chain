// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

// userid and company id is a unique natural number representing a account globally.
contract verification {
    // struct for user

    struct user {
        uint256 id;
        uint256 company_id;
        string name;
        address wallet_address;
        bool is_employed;
        bool is_manager;
        uint256 num_skill;
        uint256[] user_skills;
        uint256[] user_work_experience;
    }

    struct experience {
        string starting_date;
        string ending_date;
        string role;
        bool currently_working;
        uint256 company_id;
        bool is_approved;
    }

    struct company {
        uint256 id; //company id which is the index of id in the global company array
        string name;
        address wallet_address;
        uint256[] current_employees;
        uint256[] previous_employees;
        uint256[] requested_employees;
    }
    struct certificate {
        string url;
        string issue_date;
        string valid_till;
        string name;
        uint256 id;
        string issuer;
    }

    struct endorsment {
        uint256 endorser_id;
        string date;
        string comment;
    }

    struct skill {
        uint256 id;
        string name;
        bool verified;
        uint256[] skill_certifications;
        uint256[] skill_endorsements;
    }
    company[] public companies;
    user[] public employees;
    certificate[] public certifications;
    endorsment[] public endorsments;
    skill[] public skills;
    experience[] public experiences;

    // mapping of account's mail id with account's wallet address
    mapping(string => address) public email_to_address;
    // mapping of wallet address with account id
    mapping(address => uint256) public address_to_id;
    // mapping of wallet address with bool representing account status (Company/User)
    mapping(address => bool) public is_company;

    function memcmp(
        bytes memory a,
        bytes memory b
    ) internal pure returns (bool) {
        return (a.length == b.length) && (keccak256(a) == keccak256(b)); // Comapares the two hashes
    }

    function strcmp(
        string memory a,
        string memory b
    )
        internal
        pure
        returns (
            // string comparison function
            bool
        )
    {
        return memcmp(bytes(a), bytes(b));
    }

    // checking the function caller's wallet address from global map containing email address mapped to wallet address If the address matches, then it returns the account type (company/user).
    function login(string calldata email) public view returns (string memory) {
        require(
            msg.sender == email_to_address[email], // checking if the caller's wallet address matches the wallet address stored in the global map
            "error: incorrect wallet address used for signing in"
        );

        if (is_company[msg.sender]) {
            // checking if the caller's wallet address is a company or a user
            return "company";
        } else {
            return "user";
        }
    }

    function update_wallet_address(
        string calldata email,
        address new_address
    ) public {
        require(
            email_to_address[email] == msg.sender,
            "error: function called from incorrect wallet address"
        );
        email_to_address[email] = new_address; // updating the global map
        uint256 id = address_to_id[msg.sender]; // getting the account id of the caller
        address_to_id[msg.sender] = 0; // setting the old wallet address to 0
        address_to_id[new_address] = id; // updating the global map
    }

    function sign_up(
        string calldata email,
        string calldata name,
        string calldata acc_type // account type (Company/User)
    ) public {
        // first we check that account does not already exists
        require(
            email_to_address[email] == address(0),
            "error: user already exists!"
        );
        email_to_address[email] = msg.sender;

        if (strcmp(acc_type, "user")) {
            // for user account type
            user storage new_user = employees.push(); // creates a new user and returns the reference to it
            new_user.name = name;
            new_user.id = employees.length - 1; // give account a unique user id
            new_user.wallet_address = msg.sender;
            address_to_id[msg.sender] = new_user.id;
            new_user.user_skills = new uint256[](0);
            new_user.user_work_experience = new uint256[](0);
        } else {
            // for company account type
            company storage new_company = companies.push(); // creates a new company and returns a reference to it
            new_company.name = name;
            new_company.id = companies.length - 1; // give account a unique company id
            new_company.wallet_address = msg.sender;
            new_company.current_employees = new uint256[](0);
            new_company.previous_employees = new uint256[](0);
            address_to_id[msg.sender] = new_company.id;
            is_company[msg.sender] = true;
        }
    }

    modifier verifiedUser(uint256 user_id) {
        require(user_id == address_to_id[msg.sender]); // checking if the caller's wallet address matches the wallet address stored in the global map
        _;
    }

    function add_experience(
        uint256 user_id,
        string calldata starting_date,
        string calldata ending_date,
        uint256 company_id,
         string calldata role
    ) public verifiedUser(user_id) {
        experience storage new_experience = experiences.push();
        new_experience.company_id = company_id;
        new_experience.currently_working = false;
        new_experience.is_approved = false;
        new_experience.starting_date = starting_date;
        new_experience.role = role;
        new_experience.ending_date = ending_date;
        employees[user_id].user_work_experience.push(experiences.length - 1); // adding the experience id to the user's experience array
        companies[company_id].requested_employees.push(experiences.length - 1); // adding the experience id to the company's requested employees array
    }

    function approve_experience(uint256 exp_id, uint256 company_id) public {
        require(
            (is_company[msg.sender] &&
                companies[address_to_id[msg.sender]].id ==
                experiences[exp_id].company_id) ||
                (employees[address_to_id[msg.sender]].is_manager &&
                    employees[address_to_id[msg.sender]].company_id ==
                    experiences[exp_id].company_id),
            "error: approver should be the company account or a manager of the required company"
        ); // checking if the caller's wallet address matches the wallet address stored in the global map

        uint256 i;
        experiences[exp_id].is_approved = true;

        for (i = 0; i < companies[company_id].requested_employees.length; i++) {
            if (companies[company_id].requested_employees[i] == exp_id) {
                // removing the experience id from the company's requested employees array
                companies[company_id].requested_employees[i] = 0;
                break;
            }
        }
        for (i = 0; i < companies[company_id].current_employees.length; i++) {
            if (companies[company_id].current_employees[i] == 0) {
                // adding the experience id to the company's current employees array
                companies[company_id].requested_employees[i] = exp_id;
                break;
            }
        }
        if (i == companies[company_id].current_employees.length) {
            companies[company_id].current_employees.push(exp_id); // adding the experience id to the company's current employees array
        }
    }

    constructor() {
        // creating a dummy user and company Now let's say an employee no longer works at a particular company - to remove the employee from the company's employee list we have two options:
        user storage dummy_user = employees.push();
        dummy_user.name = "dummy";
        dummy_user.wallet_address = msg.sender;
        dummy_user.id = 0;
        dummy_user.user_skills = new uint256[](0);
        dummy_user.user_work_experience = new uint256[](0);
    }

    function approve_manager(uint256 employee_id) public {
        // will take the employee id as input and verify that the account calling the function has a "company" account type and that the employee is of the same company

        // then make sure that this employee id is present in the company's "current employees" list.
        // If these checks pass, it will give that employee a manager tag by setting its is_manager boolean to true.
        // If the employee is already a manager, it will throw an error.

        require(is_company[msg.sender], "error: sender not a company account"); // checking if the caller's wallet address is a company or a user
        require(
            employees[employee_id].company_id == address_to_id[msg.sender],
            "error: user not of the same company"
        );
        require(
            !(employees[employee_id].is_manager),
            "error: user is already a manager"
        );
        employees[employee_id].is_manager = true;
    }

    function add_skill(
        uint256 userid,
        string calldata skill_name
    ) public verifiedUser(userid) {
        // the modifier that we created above
        skill storage new_skill = skills.push();

        employees[userid].user_skills.push(skills.length - 1);
        new_skill.name = skill_name;
        new_skill.verified = false;
        new_skill.skill_certifications = new uint256[](0);
        new_skill.skill_endorsements = new uint256[](0);
    }

    function add_certification(
        // adding a certification to the blockchain
        uint256 user_id,
        string calldata url,
        string calldata issue_date,
        string calldata valid_till,
        string calldata name,
        string calldata issuer,
        uint256 linked_skill_id
    ) public verifiedUser(user_id) {
        // the modifier that we created above
        certificate storage new_certificate = certifications.push(); // creates a new certificate and returns a reference to it
        new_certificate.url = url;
        new_certificate.issue_date = issue_date;
        new_certificate.valid_till = valid_till;
        new_certificate.name = name;
        new_certificate.id = certifications.length - 1;
        new_certificate.issuer = issuer;
        skills[linked_skill_id].skill_certifications.push(new_certificate.id); // adding the certificate id to the skill's certifications array
    }

    function endorse_skill(
        uint256 user_id,
        uint256 skill_id,
        string calldata endorsing_date,
        string calldata comment
    ) public { // this function will be called by a user to endorse a skill
        endorsment storage new_endorsemnt = endorsments.push(); 
        new_endorsemnt.endorser_id = address_to_id[msg.sender]; // the address of the user who is endorsing the skill the id will be stored in endorsments array
        new_endorsemnt.comment = comment;
        new_endorsemnt.date = endorsing_date;

        skills[skill_id].skill_endorsements.push(endorsments.length - 1);

        if (employees[address_to_id[msg.sender]].is_manager) {
            if (
                employees[address_to_id[msg.sender]].company_id ==
                employees[user_id].company_id
            ) {
                skills[skill_id].verified = true;
            }
        }
    }
}
