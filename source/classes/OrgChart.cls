/**
* @author KevinSwiggum
* Copyright 2011 Radial Web Solutions LLC
*/
public with sharing class OrgChart {
	
	static Boolean chatterEnabled = true;
		
	/**
	* populates a list of RoleWithUsers object for the given selectedRoleIds
	* @author KevinSwiggum
	*/
	public static List<RoleWithUsers> getRolesWithUsers(Set<ID> roleIds) {
		List<RoleWithUsers> rolesWithUsersList = new List<RoleWithUsers>();
		List<UserRole> roles = new List<UserRole>();
		try {
			roles = [SELECT ID
						, Name
						, ParentRoleId
						, (SELECT ID, name, title, email, phone, SmallPhotoUrl FROM Users WHERE IsActive=true) 
						FROM UserRole 
						WHERE parentRoleId IN :roleIds 
						OR ID IN :roleIds
						ORDER BY ParentRoleId NULLS FIRST, ID];
		} catch (System.Requiredfeaturemissingexception e) {
			//catches an error in the event that chatter is not enabled in this org.
			roles = [SELECT ID
						, Name
						, ParentRoleId
						, (SELECT ID, name, title, email, phone FROM Users WHERE IsActive=true) 
						FROM UserRole 
						WHERE parentRoleId IN :roleIds 
						OR ID IN :roleIds
						ORDER BY ParentRoleId NULLS FIRST, ID];
			chatterEnabled = false;
		}
		//Populate the list
		rolesWithUsersList = new List<RoleWithUsers>();
		for (UserRole ur : roles) {
			rolesWithUsersList.add(new RoleWithUsers(ur, (roleIds.contains(ur.id))));
		}
		
		return rolesWithUsersList;
	}
	
	public static Set<ID> getTopUserRoleIds() {
		Set<Id> roleIds = new Set<Id>();
		List<UserRole> topRoles = [SELECT ID FROM UserRole WHERE parentRoleId = null];
		for (UserRole ur : topRoles) {
			roleIds.add(ur.ID);
		}
		return roleIds;
	}
	
	public static Set<ID> getAllRoleIds() {
		Set<Id> roleIds = new Set<ID>();
		List<UserRole> topRoles = [SELECT ID FROM UserRole LIMIT 500];
		for (UserRole ur : topRoles) {
			roleIds.add(ur.ID);
		}
		return roleIds;
	}
	
	/**
	* Inner class that holds the UserRole (with the Users related list already populated).
	* Provides helper methods for formatting output text
	* @author KevinSwiggum
	*/
	public class RoleWithUsers {
		public UserRole role {get; set;}
		public Boolean isExpanded {get; set;}
		
		/**
		* Contructor. Expanded tells the class if this role has been clicked on and expanded
		* @author KevinSwiggum
		*/
		public RoleWithUsers(UserRole rl, Boolean expanded) {
			this.role = rl;
			this.isExpanded = expanded;
		}
		
		/**
		* returns the UserRoleId
		* @author KevinSwiggum
		*/
		public String getId() {
			return role.id;
		}
		
		/**
		* Returns the ID of the parent role
		* @author KevinSwiggum
		*/
		public String getParent() {
			return role.parentRoleId;
		}
		
		/**
		* returns the name of the role
		* @author KevinSwiggum
		*/
		public String getTitle() {
			return role.name;
		}
		
		
		/**
		* Returns an HTML-formated string representing users within this role. Done here instead of VF because of the requirements of Google Visualization. Components didn't work well
		* @author KevinSwiggum
		*/
		public String getRoleBody() {
			if (role != null) {
				//String roleBody = '';
				String roleBody = '<div class="chartCell"> <div class="cellTitle">' +
									'<a href="javascript://nop/" onclick="loadMore(\''+role.id+'\');">';
									
				if (!isExpanded)
					roleBody += '<img class="expandIcon" src="/s.gif" style="float:left;"/>';
				
				roleBody += role.name + '</a></div><div style="clear:both;"></div>';
				
				if (role.users.size() > 0) {
					String template = '<a target="_blank" href="/{!id}" title="View Profile">';
					if (chatterEnabled) {
						template += '<img class="chartCellIcon" src="{!SmallPhotoUrl}"/>';
					}
					template += '<div class="cellTitle">{!name}</div>' +
								'<div class="chartCellBody" style="margin:0px;padding:1px;">{!title}</div>' +
								'<div class="chartCellBody" style="margin:0px;padding:1px;">{!email}</div>' +
								'<div class="chartCellBody" style="margin:0px;padding:1px;">{!phone}</div>' +
								'</a><div style="clear:both;height:10px;"></div>';
	
					
					for (User u : role.users) {
						String uBody = template;
						uBody = replace(uBody, 'id', u);
						if (chatterEnabled) uBody = replace(uBody,'SmallPhotoUrl', u);
						uBody = replace(uBody,'name', u);
						uBody = replace(uBody,'title', u);
						uBody = replace(uBody,'email', u);
						uBody = replace(uBody,'phone', u);
						
						roleBody += uBody;
						
					}
				} else {
					roleBody += '<i>No Users Defined</i>';
				}
				
				roleBody += '</div>';
				return roleBody;			
			}
			return '';
		}

	}
	
	/**
	* replaces template string with an object's value
	* @author KevinSwiggum
	*/
	static String replace(String inString, String key, sObject o) {
		
		String objectValue = '';
		try {
			Object obj = o.get(key);
			objectValue = obj != null ? String.valueOf(obj) : '';

		} catch (Exception e) {}
		
		
		return inString.replace('{!' + key + '}', objectValue);
	}
	
	
}