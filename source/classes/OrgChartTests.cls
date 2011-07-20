/**
* @author KevinSwiggum
* Copyright 2011 Radial Web Solutions LLC
*/
@isTest
private class OrgChartTests {


	static testMethod void testOrgChart() {
		Set<ID> roleIds = OrgChart.getTopUserRoleIds();
		List<OrgChart.RoleWithUsers> roleList = OrgChart.getRolesWithUsers(roleIds);
		for (OrgChart.RoleWithUsers rwu : roleList) {
			rwu.getParent();
			rwu.getId();
			rwu.getTitle();
			rwu.getRoleBody();
		}
		 
		roleIds = OrgChart.getAllRoleIds();
		System.assert(roleIds.size() > 0);
	}

	public static testMethod void testOrgChartController() {
		OrgChartController ctl = new OrgChartController();
		List<OrgChart.RoleWithUsers> roleList = ctl.getRolesWithUsersList();
		OrgChart.RoleWithUsers lastVal = roleList[roleList.size()-1];
		ctl.roleId = lastVal.getId();
		ctl.loadMore();
		roleList = ctl.getRolesWithUsersList();
		
		System.assert(roleList.size() > 0);
		ctl.expandAll();
		ctl.collapseAll();
		
	}

}