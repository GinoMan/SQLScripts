/* The script below adds the author as an administrator to the product's internal user system's database */
BEGIN
/* Determins whether or not all fingerprints should be entered or just two fingers */
DECLARE @TwoFingersOnly BIT;
SELECT @TwoFingersOnly = 0;

/* Create the user */
PRINT 'Inserting Gino Vincenzini into Users Table'
INSERT INTO [product].[object].[usersTable] (firstName, lastName, [suffix], [middleInitial], [address], [address2], [city], 
	[state], [zipCode], [phoneNumber], phoneType, accountNumber, pinRequired, tempWorker, email)
VALUES ('Firstname', 'Lastname', '', 'Initial', 'Department', 'Address', 'City', 'PA', '12345', 'phoneNumber', 0, 123, 0, 0, 'email@domain.com')

/* Declare variables for the userNumber, GroupNumber, and empNumber */
DECLARE @ID int;
SET @ID = (SELECT userNumber FROM product.object.usersTable WHERE email='email@domain.com');

/* Make the user an employee with 30 minutes access duration */
PRINT 'Make Gino an employee with 30 minutes access duration'
INSERT INTO [product].[object].[user.employeeTable] (userNumber, inactiveRecord, accessDuration)
VALUES (@ID, 0, 30);

PRINT 'Determine group and set group ID or set it to 0'
DECLARE @GID int;
SELECT @GID = userGroupNumber from [product].[object].[user.Group.idsTable] WHERE readableGroupName LIKE 'Manager' OR readableGroupName LIKE 'Technician' 
IF (@@ROWCOUNT = 0 OR @@ROWCOUNT > 1)
BEGIN
SELECT @GID = 0;
END

/* Associate the user to a group */
PRINT 'Associate the User to the Group'
INSERT INTO [product].[object].[user.groupsTable] (userGroupNumber, userNumber)
VALUES (@GID, @ID);

DECLARE @EID int;
SET @EID = (SELECT empNumber FROM [product].[object].[user.employeeTable] WHERE userNumber = @ID);

/* Insert the generic password into the database for the new employee */
PRINT 'Set the generic password for the Employee ID'
INSERT INTO [product].[object].[user.employeeTable.passwordValues] (empNumber, [password])
VALUES (@EID, 0x0123456789); /* Magic number for password, obfuscated */

/* F-Prints inserted into templates; Pointer and Middle Only */
IF (@TwoFingersOnly = 1)
BEGIN
/* In the section below, all of the hashvalues and fingerprint data are obfuscated */
PRINT 'Insert Gino''s Pointer and Middle Fingers into the fingerprint templates'
INSERT INTO [product].[object].[user.Fingerprints] (userNumber, userAccountCodeNumber, fingerHash, fingerData, inactiveRecord)
VALUES 	(@ID, 'hashvalue', 0x00000000, 123, 0),
		(@ID, 'hashvalue', 0x11111111, 123, 0);
END
ELSE
BEGIN
PRINT 'Insert All of Gino''s Fingerprints.'
INSERT INTO [product].[object].[user.Fingerprints] (userNumber, userAccountCodeNumber, fingerHash, fingerData, inactiveRecord)
VALUES 	(@ID, 'hashvalue', 0x22222222, 123, 0),
		(@ID, 'hashvalue', 0x33333333, 123, 0),
		(@ID, 'hashvalue', 0x44444444, 123, 0),
		(@ID, 'hashvalue', 0x55555555, 123, 0),
		(@ID, 'hashvalue', 0x66666666, 123, 0),
		(@ID, 'hashvalue', 0x77777777, 123, 0),
		(@ID, 'hashvalue', 0x88888888, 123, 0),
		(@ID, 'hashvalue', 0x99999999, 123, 0),
		(@ID, 'hashvalue', 0x11111111, 123, 0),
		(@ID, 'hashvalue', 0x00000000, 123, 0);
END

/* Set up permissions */
PRINT 'Insert Gino''s Permissions giving him full access to everything'
INSERT INTO [product].[object].[user.permissionTable] (userNumber, [permissionCode])
VALUES (@ID, '00011011000000110000');

/* Set the user to be an active maintainer */
PRINT 'Set Gino to be an active maintainer'
INSERT INTO [product].[object].[user.MaintainerTable] (userNumber, inactiveRecord)
VALUES (@ID, 0);

/* Add the user to the list of admins */
PRINT 'Make Gino an Admin'
INSERT INTO [product].[object].[user.AdminTable] (userNumber, inactiveRecord)
VALUES (@ID, 0);

PRINT 'Test to see if there is a 24/7 or TwentyFour timegroup'
(SELECT timeGroupNumber FROM [product].[object].[device.Entry.TimeGroupTable] 
WHERE ([TimeGroupNameText] = '24/7' AND inactiveRecord = 0) OR ([TimeGroupNameText] = 'TwentyFour' AND inactiveRecord = 0)) 


IF (@@ROWCOUNT = 0)
BEGIN
PRINT 'Time Group not found, Creating New Timegroup' 
INSERT INTO [product].[object].[device.Entry.TimeGroupTable] ([TimeGroupNameText], startDayOfWeek, startTime, endDayOfWeek, endTime, inactiveRecord)
	VALUES ('TwentyFour', 0, '00:00', 6, '23:59', 0);
END

/* Give the user a time-group */
PRINT 'Give Gino the 24/7 Time group.'
INSERT INTO [product].[object].[user.LockSet.TimeGroupTable] (userNumber, timeGroupNumber)
VALUES (@ID, (SELECT timeGroupNumber FROM [product].[object].[device.Entry.TimeGroupTable] WHERE ([TimeGroupNameText] = '24/7' AND inactiveRecord = 0) OR ([TimeGroupNameText] = 'TwentyFour' AND inactiveRecord = 0)));
END
GO