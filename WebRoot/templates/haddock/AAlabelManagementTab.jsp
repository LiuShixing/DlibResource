

<%@page import="java.sql.ResultSet"%>
<%@page import="dr.DBManager"%>
<%@page import="org.apache.wiki.WikiSession"%>
<%@page import="org.apache.wiki.auth.user.UserProfile"%>
<%@ page import="java.security.Principal" %>
<%@ page import="java.text.MessageFormat" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.wiki.WikiContext" %>
<%@ page import="org.apache.wiki.auth.*" %>
<%@ page import="org.apache.wiki.auth.AuthorizationManager" %>
<%@ page import="org.apache.wiki.auth.PrincipalComparator" %>
<%@ page import="org.apache.wiki.auth.authorize.Group" %>
<%@ page import="org.apache.wiki.auth.permissions.GroupPermission" %>
<%@ page import="org.apache.wiki.auth.authorize.GroupManager" %>
<%@ page import="org.apache.wiki.preferences.Preferences" %>
<%@ page import="org.apache.log4j.*" %>
<%@ page errorPage="/Error.jsp" %>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.*" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>
<fmt:setLocale value="${prefs.Language}" />
<fmt:setBundle basename="templates.default"/>
<%
String delete_label = request.getParameter("delete_label");
if(delete_label != null)
{
	String sql="delete from labels where label=?";
	DBManager db=new DBManager(sql);
	db.pst.setString(1, delete_label);
	int rs = db.pst.executeUpdate();
	db.close();
}

String sql="select label from labels";
DBManager db=new DBManager(sql);
ArrayList<String> labels = new ArrayList<>();
ResultSet rs = db.pst.executeQuery();
while(rs.next())
{
	labels.add(rs.getString(1));
}
rs.close();
db.close();


%>

<form action="UserPreferences.jsp?#section-label"
      class="hidden"
        name="deleteLabelForm" id="deleteLabelForm"
      method="POST" accept-charset="UTF-8">
  <input type="hidden" name="delete_label"/>
  <input type="submit" name="ok"
   data-modal="+ .modal"
        value="删除" />
  <div class="modal">请确认是否删除此标签！</div>
</form>


<div>

	<table class="table">
<%
for(String s:labels)
{
 %>
		<tr>
		<td> <%=s %></td>
		<td>
		<button class="btn btn-xs btn-danger" onclick="document.deleteLabelForm.delete_label.value ='<%=s %>';document.deleteLabelForm.ok.click();" >
          删除
        </button>
		</td>
		</tr>
<%
}
 %>
	</table>
</div>
