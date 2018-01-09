

<%@page import="servlet.MyUtil"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="servlet.Article"%>
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
	String fullName=(String)request.getSession().getAttribute("curr_view_user");
	String pageid=request.getParameter("page");
	String goPage="Wiki.jsp?page="+pageid+"&fullName="+fullName;
%>

 <%

	   String type=request.getParameter("type");
	   String sql=null;
	   if(type==null || type.equals("null"))
	   		sql="select * from articles where author=?";
	   	else if(type.equals("report"))
	   		sql="select * from articles where type='report' and author=?";
	   	else
	   		sql="select * from articles where type='other' and author=?";
	   	sql+=" order by time desc";
       DBManager db=new DBManager(sql);
       ArrayList<Article> needs = new ArrayList<Article>();
       db.pst.setString(1, fullName);
       ResultSet rs=db.pst.executeQuery();
       while(rs.next())
       {
            Article article = new Article();
            article.setId(rs.getString("id"));
            article.setTitle(rs.getString("title"));
            article.setAuthor(rs.getString("author"));
            article.setTime(rs.getDate("time"));
            article.setType(rs.getString("type"));
            needs.add(article);
       }
       rs.close();
       db.close();
		
		
		String itemsPerPageString = request.getParameter("itemsPerPage");
		String currPageString = request.getParameter("currPage");
		int currPage=1;
		if(currPageString==null || currPageString.equals("") )currPageString="1";
		currPage=Integer.parseInt(currPageString);
		
		int itemsPerPage=0;
		if(itemsPerPageString==null)itemsPerPage = MyUtil.LIST_COUNT;
		
		int total = needs.size();
		int totalPage = total/itemsPerPage;
		if(total % itemsPerPage != 0){
		    totalPage += 1;
		}
		Vector<Integer> pageArr = new Vector<Integer>();
		int start = 1;
		
		final int NUM=10;
		if(currPage >= NUM){
		     start = currPage/NUM * NUM;
		 }
		int num = start;
		while(!(num > totalPage || num > start + NUM)){
		     pageArr.add(new Integer(num));
		    ++num;
		}
	 	
	 	ArrayList<Article> shows = new ArrayList<Article>();
		
		int index = itemsPerPage*(currPage-1);
		while (index<total && index<itemsPerPage*currPage)
		{
			shows.add(needs.get(index));
			index++;
		} 
		
		Map<String,String> m = new HashMap<String,String>();
		
		m.put("report","读书报告");
		m.put("other","其他");
		
		if(shows.size() ==0)
		{
 %>
   <div class="error text-align-center">没有文章</div>
 <%
        }else{
  %>
 
 
 <table  id="resourceTable" class="hovertable">
  <tr>
    <th width="10%" ><div class="table_center">日期</div></th>
    <th width="60%" ><div class="table_center">标题</div></th>
    <th width="20%"  ><div class="table_center">作者</div></th>
  </tr>
  
 <%
    
    SimpleDateFormat df=new SimpleDateFormat("yyyy-MM-dd");
    final int MAXATTACHNAMELENGTH=400;
    
    for(Article art:shows)
    {
       String sname =art.getTitle();
      
      if( sname.length() > MAXATTACHNAMELENGTH ) sname = sname.substring(0,MAXATTACHNAMELENGTH) + "...";
  %>
	<tr>
    <td class="table_center"><%=df.format(art.getTime())%> </td>
    <td class="resourceNameClass"><a class="resourceListType" href="<%=goPage %>&type=<%=art.getType() %>#section-personalArticles ">[<%=m.get(art.getType()) %>]</a>
  
    <wiki:LinkTo page="<%=String.valueOf(art.getId()) %>">
		<%=sname %>
	</wiki:LinkTo>

	</td>
    <td class="table_center"><%=art.getAuthor() %> </td>
    </tr>
 <%
    }
  %>
 
</table>

 




<!-- ************************************ -->


 <%


%>

<div id="pageControl" align="center">


<!-- 上一页 按钮 -->
<%
if(total >itemsPerPage)
{
     if(currPage != 1)
     {
 %>
  <a href="<%=goPage %>&type=<%=type %>&currPage=<%=currPage-1 %>#section-personalArticles">
  <input type="button" value="上一页" class="mybutton myblue"/>
  </a>
 
 <%
     }else
     {
 %> 
 
  <input type="button" value="上一页" class="mybutton mywhite" disabled="disabled"/>
 
 <%
     }
  %> 
  
  
  
  <!-- 页数列表 -->
 <%
      for(int p:pageArr)
      {
           if(p==currPage)
           {
  %>
             <a href="<%=goPage %>&type=<%=type %>&currPage=<%=p %>#section-personalArticles" >
                <input type="button" value="<%=p %>" class="pageButton myblue"/>
             </a>
  <%
            }else{
   %>
              <a href="<%=goPage %>&type=<%=type %>&currPage=<%=p %>#section-personalArticles"  >
                 <input type="button" value="<%=p %>" class="pageButton mywhite"/>
              </a>
  
 <% 
         }
      }
  %>
  
 


 
<!-- 下一页 按钮 -->
<%
     if(currPage != totalPage)
     {
 %>
  <a href="<%=goPage %>&type=<%=type %>&currPage=<%=currPage+1 %>#section-personalArticles">
  <input type="button" value="下一页" class="mybutton myblue"/>
  </a>
 
 <%
     }else
     {
 %> 
  
       <input type="button" value="下一页" class="mybutton mywhite" disabled="disabled" />

 <%
     }
  %> 


<!-- 直接跳转                 注意，该页与个人资源也会最终显示在一个html中，id不能重复-->
共<%=totalPage %>页 -向<input type="text" id="jumpToText_art" value="<%=currPage %>" size="2" />页 
<a href="<%=goPage %>&type=<%=type %>&currPage= " id="jumpToLink_art">
<input type="button" value="跳转" class="mybutton myblue" onclick="


        var page = document.getElementById('jumpToText_art').value;
	    var a=document.getElementById('jumpToLink_art');
	    if(!(Math.floor(page) == page) || page > <%=totalPage %> || page < 1 ){
	        a.href='#';
	        document.getElementById('jumpToText_art').value=<%=currPage %>;
	        alert('没有该页');
	       
	    }else{
	          a.href+=page;
	          a.href+='#section-personalArticles';
	    }



"/>
</a>

<%
    }//end if(total >itemsPerPage)
 %>
</div>
 


<%
     } //end if no resource
 
 %>
 
