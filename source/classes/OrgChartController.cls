/**
* @author KevinSwiggum
* Copyright 2011 Radial Web Solutions LLC
*/
public with sharing class OrgChartController {

	transient List<OrgChart.RoleWithUsers> rolesWithUsersList;
	public String roleId {get; set;}
	private Set<ID> selectedRoleIds = new Set<ID>();
	
	/**
	* Constructor grabs the top level role(s) and their direct children
	* @author KevinSwiggum
	*/
	public OrgChartController() {
		init();
	}
	
	/**
	* sets the initial set of role ids to just the top role ids
	* @author KevinSwiggum
	*/
	private void init() {
		selectedRoleIds = OrgChart.getTopUserRoleIds();
	}
	
	/**
	* sets the role list back to null so that it will be re-pulled
	* @author KevinSwiggum
	*/
	private void clearRoleList() {
		rolesWithUsersList = null;
	}
	
	/**
	* populates a list of RoleWithUsers object for the given selectedRoleIds
	* @author KevinSwiggum
	*/
	public List<OrgChart.RoleWithUsers> getRolesWithUsersList() {
		if (rolesWithUsersList == null) {
			rolesWithUsersList = OrgChart.getRolesWithUsers(selectedRoleIds);		
		}
		return rolesWithUsersList;						
	}

	/**
	* user clicked on a role to load children for that role
	* @author KevinSwiggum
	*/
	public PageReference loadMore() {
		if (roleId != null) {
			selectedRoleIds.add(roleId);
			clearRoleList();
		}
		return null;
	}
	
	/**
	* Pull all roles in the organization
	* @author KevinSwiggum
	*/
	public PageReference expandAll() {
		selectedRoleIds = OrgChart.getAllRoleIds();
		clearRoleList();
		
		return Page.OrgChart;
	}
	
	/**
	* Collapse back down to the default view (parent and direct children)
	* @author KevinSwiggum
	*/
	public PageReference collapseAll() {
		clearRoleList();
		init();
		return Page.OrgChart;
	}
	

}