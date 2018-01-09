

<%@page import="dr.DBManager"%>
<%@page import="servlet.MyUtil"%>
<%@page import="servlet.ResourceInfo"%>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="org.apache.wiki.*" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8" %>
<fmt:setLocale value="${prefs.Language}" />
<fmt:setBundle basename="templates.default"/>
<%
  WikiContext c = WikiContext.findContext(pageContext);
%>
<c:set var="frontpage" value="<%= c.getEngine().getFrontPage() %>" />

<wiki:Plugin plugin="IfPlugin" args="page='TitleBox' contains='\\\\S' " >[{InsertPage page=TitleBox class='titlebox alert' }]</wiki:Plugin>

<%
        ServletContext app = request.getServletContext();
        
        
        String ResourceTitle=null;
        if(app!=null)
        {
           Map<String,ResourceInfo> mp=(Map<String,ResourceInfo>)app.getAttribute(MyUtil.RESOURCE_INFO_MP);
           if(mp!=null && c!=null)
           {
               WikiPage wp=c.getPage();
               if(wp!=null && wp.getName()!=null)
               {
                  ResourceInfo info = mp.get(wp.getName().toLowerCase());
                  if(info!=null)
                  {
                      ResourceTitle = info.getTitle();
                  }
                  else
                  {
                     ResourceTitle =wp.getName();
                  }
               }
              
           }else{
               System.out.println("AAheader.jsp:mp==null");
           }
        }else{
           System.out.println("AAheader.jsp:app==null");
        }
        if(ResourceTitle==null)ResourceTitle="无标题";
       
        
     String pageid=request.getParameter("page");
     if(pageid==null)pageid="zanwei";
     
     
 %>
<div class="header">

  <div class="topline">

    <div class="cage pull-left">
    <a class="logo pull-left"
        href="<wiki:Link page='${frontpage}' format='url' />"
       title="资源列表 ">Dlib资源</a>

    </div>

    <wiki:Include page="UserBox.jsp" />
    <wiki:Include page="SearchBox.jsp" />
    
   <wiki:Include page="AAvisitCounter.jsp" />

<%
 if(pageid.getBytes()[0]=='3') //个人主页
 {
	 String fullName=request.getParameter("fullName");
	HttpSession sess=request.getSession();
	if(fullName!=null)
	{
		sess.setAttribute("curr_view_user", fullName);
	}
	else{
		fullName=(String)sess.getAttribute("curr_view_user");
	}
	String page_name=fullName+"的个人中心";
 %>
     <div class="pagename"">
    <%=page_name %>
   
    </div> 
<%
}
%>

  </div>
 <%--  <div class="breadcrumb">
    <fmt:message key="header.yourtrail"/><wiki:Breadcrumbs separator="<span class='divider'></span>" />
  </div> --%>

</div>