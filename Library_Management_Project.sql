create database Library_Management;
# Library management system 

use Library_Management;
# CREATE THE BRANCH TABLE 
drop table if exists branch;
CREATE TABLE branch (
    branch_id VARCHAR(10) PRIMARY KEY,
    manager_id VARCHAR(10),
    branch_address VARCHAR(55),
    contact_no VARCHAR(15)
);

# CREATE TABLE EMPLOYEE
CREATE TABLE employee (
    emp_id VARCHAR(10) PRIMARY KEY,
    emp_name VARCHAR(30),
    position VARCHAR(20),
    salary FLOAT,
    branch_id VARCHAR(10)
);

# CREATE TABLE BOOKS
CREATE TABLE books (
    isbn VARCHAR(25) PRIMARY KEY,
    book_title VARCHAR(100),
    category VARCHAR(30),
    rental_price FLOAT,
    status VARCHAR(15),
    author VARCHAR(50),
    publisher VARCHAR(60)
);

# CREATE TABLE MEMBERS 
CREATE TABLE members (
    member_id VARCHAR(10) PRIMARY KEY,
    member_name VARCHAR(30),
    member_address VARCHAR(100),
    reg_date DATE
);

# CREATE TABLE ISSUED_STATUS

CREATE TABLE issued_status (
    issued_id VARCHAR(10) PRIMARY KEY,
    issued_member_id VARCHAR(10),
    issued_book_name VARCHAR(100),
    issued_date DATE,
    issued_book_isbn VARCHAR(25),
    issued_emp_id VARCHAR(10)
);

# CREATE TABLE RETURN_STATUS
CREATE TABLE return_status (
    return_id VARCHAR(10) PRIMARY KEY,
    issued_id VARCHAR(10),
    return_book_name VARCHAR(100),
    return_date DATE,
    return_book_isbn VARCHAR(25)
);

# After importing the data Now setting up the foreign keys 
ALTER TABLE employee
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employee(emp_id);


SELECT *
FROM return_status
WHERE issued_id NOT IN (
    SELECT issued_id
    FROM issued_status
);

select * from books;
select * from branch;
select * from members;
select * from employee;
select * from return_status;
select *from issued_status;

 
-- TASK 1 : To create a record "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
insert into books values ("978-1-60129-456-2",'To Kill a Mockingbird','Classic',6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address 

update members set member_address = "107 Bridget St" where member_id="C102";
 
-- **Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status WHERE issued_id='IS121';


-- **Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status WHERE issued_emp_id ='E101';

-- **Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

select issued_member_id , count(*) from issued_status group by issued_member_id;

### 3. CTAS (Create Table As Select)
-- - **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
create table issues_books as 
select b.* , count(*) from books b
join issued_status s on b.isbn=s.issued_book_isbn
group by b.isbn;
select * from issues_books;



### 4. Data Analysis & Findings

-- The following SQL queries were used to address specific questions:

-- Task 7. **Retrieve All Books in a Specific Category**:
select * from books where category='Fiction';

-- 8. **Task 8: Find Total Rental Income by Category**:
select category , sum(rental_price) from books group by category;

-- 9. **List Members Who Registered in the Last 180 Days**:
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL 180 day; 

# OR 
select * from members 
where datediff(Curdate() , reg_date) <=180;

-- Task 10. **List Employees with Their Branch Manager's Name and their branch details**:
select e1.* , b.branch_id , e2.emp_name as manager_name
from employee e1 join branch b 
on e1.branch_id = b.branch_id 
join 
employee e2 
on b.manager_id=e2.emp_id;

-- Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold 7 USD**:
Create table Rental_7 as 
select * from books 
where rental_price>7;
select * from Rental_7;

-- Task 12: **Retrieve the List of Books Not Yet Returned**
select * from issued_status as t1
left join
return_status as t2 
on t1.issued_id=t2.issued_id
where t2.return_id is NULL;

## Advanced SQL Operations

# adding new column to return_status 
alter table return_status 
ADD column book_quality varchar(20) default 'Good';

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
    
select * from return_status;
# Inserting Some more data into the table 
select * from issued_status;
INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL 24 day,'978-0-553-29698-2','E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL 13 day,'978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL 7 day,  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL 32 day,  '978-0-375-50167-0', 'E101');

/* **Task 13: Identify Members with Overdue Books**  
-- Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN 
members as m
    ON m.member_id = ist.issued_member_id
JOIN 
books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1;


/*    
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/
DELIMITER $$

CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10),
    IN p_book_quality VARCHAR(15)
)

BEGIN

    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);

    -- Insert return record
    INSERT INTO return_status (
        return_id,
        issued_id,
        return_date,
        book_quality
    )
    VALUES (
        p_return_id,
        p_issued_id,
        CURDATE(),
        p_book_quality
    );

    -- Fetch book details
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Update book availability
    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    -- Display message
    SELECT CONCAT(
        'Thank you for returning the book: ',
        v_book_name
    ) AS message;

END $$

DELIMITER ;

# TESTING THE PROCEDURE - ADD_RETURN_RECORDS() 

Call add_return_records('RS139','IS135','Good');


call add_return_records('RS141','IS106','Good');
call add_return_records('RS142','IS136','Good');
 
 
/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/

Create table Branch_Reports AS
select 
b.branch_id ,
b.manager_id , 
count(ist.issued_id) as No_books_issued,
count(rs.return_id) as No_books_returns,
sum(bk.rental_price) as total_revenue
from issued_status as ist 
JOIN
employee as e 
on e.emp_id=ist.issued_emp_id
JOIN 
branch as b 
on e.branch_id=b.branch_id
LEFT JOIN 
return_status as rs 
on rs.issued_id=ist.issued_id
JOIN 
books as bk 
on ist.issued_book_isbn=bk.isbn
group by 1 , 2;

select * from Branch_Reports;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 12 months.

Create table Active_Members AS
select * from members 
where member_id in (select 
distinct issued_member_id 
from issued_status 
where issued_date >= current_date()-Interval 12 Month);

SELECT * FROM Active_Members;

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.


Select 
e.emp_name , 
b.* , 
count(ist.issued_id) as no_book_issued
from issued_status as ist 
join 
employee as e 
on e.emp_id=ist.issued_emp_id 
JOIN 
branch as b 
on e.branch_id=b.branch_id
group by 1,2;


/*Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books.  */

select m.member_name , 
ist.issued_book_name ,
count(ist.issued_id) as NO_of_times from members m 
JOIN 
issued_status ist 
on m.member_id=ist.issued_member_id
JOIN
return_status rs 
on ist.issued_id=rs.issued_id
where rs.book_quality='Damaged'
group by 1,2;





/*
Task 19: Stored Procedure Objective: 
Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: 
The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/

DELIMITER $$

CREATE PROCEDURE issue_book(
    IN p_issued_id VARCHAR(10),
    IN p_issued_member_id VARCHAR(30),
    IN p_issued_book_isbn VARCHAR(30),
    IN p_issued_emp_id VARCHAR(10)
)

BEGIN

    DECLARE v_status VARCHAR(10);

    -- Check book availability
    SELECT status
    INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    -- If book is available
    IF v_status = 'yes' THEN

        -- Insert record into issued_status
        INSERT INTO issued_status(
            issued_id,
            issued_member_id,
            issued_date,
            issued_book_isbn,
            issued_emp_id
        )
        VALUES (
            p_issued_id,
            p_issued_member_id,
            CURDATE(),
            p_issued_book_isbn,
            p_issued_emp_id
        );

        -- Update book status
        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        -- Success message
        SELECT CONCAT(
            'Book issued successfully for ISBN : ',
            p_issued_book_isbn
        ) AS message;

    ELSE

        -- Failure message
        SELECT CONCAT(
            'Sorry, the requested book is unavailable. ISBN : ',
            p_issued_book_isbn
        ) AS message;

    END IF;

END $$

DELIMITER ;

select  * from books
where isbn ='978-0-553-29698-2';
select  * from books
where isbn =
'978-0-451-52994-2' ;

select * from issued_status where issued_book_isbn ='978-0-451-52994-2';

select * from issued_status;

# TESTING THE PROCEDIRE - ISSUE-BOOK()
CALL issue_book('IS155','C108','978-0-553-29698-2','E104');

CALL issue_book('IS130','C106','978-0-451-52994-2','E101');


/*Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines  */

select ist.issued_member_id , 
count(ist.issued_id) as no_books_overdue,
sum((datediff(Curdate(),ist.issued_date) - 30) * 0.50 ) AS total_fine 
from issued_status ist  
left JOIN 
return_status rs 
on rs.issued_id = ist.issued_id 
where rs.return_id is NULL and 
datediff(curdate() , ist.issued_date) >30
group by ist.issued_member_id;

