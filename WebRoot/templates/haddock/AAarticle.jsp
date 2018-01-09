<%@page import="java.text.DateFormat"%>
<%@page import="servlet.Article"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="dr.DBManager"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="servlet.MyUtil"%>
<%@page import="servlet.ResourceInfo"%>
<%@ page import="org.apache.wiki.*" %>
<%@ page import="org.apache.wiki.auth.*" %>
<%@ page import="org.apache.wiki.ui.progress.*" %>
<%@ page import="org.apache.wiki.auth.permissions.*" %>
<%@ page import="java.security.Permission" %>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>
<fmt:setLocale value="${prefs.Language}" />
<fmt:setBundle basename="templates.default"/>

<%
String goPage="Home.jsp?tag=article";


String sql0="select label from labels";
DBManager db0=new DBManager(sql0);
ArrayList<String> arrlabels = new ArrayList<>();
ResultSet rs0 = db0.pst.executeQuery();


while(rs0.next())
{
	arrlabels.add(rs0.getString(1));
}
rs0.close();
db0.close();
%>

  
<div class="articleList">

<div class="art_herder">
<% 
 String type=request.getParameter("type");
String req_labels = request.getParameter("labels");
Set<String> check_labels = new HashSet<>();
if(req_labels != null)
{
	for(String s:req_labels.split("/"))
	{
		check_labels.add(s);
	}
}

for(String s:arrlabels)
{
	if(check_labels.contains(s))
	{
 %>
		<label><input name="labels" type="checkbox" value="<%=s %>" checked=true /><%=s %></label>
<%
	}
	else{
 %>
 		<label><input name="labels" type="checkbox" value="<%=s %>" /><%=s %></label>
 <%
	}
}
%>
<a id="ljump" href="<%=goPage %>&type=<%=type %>">
 <input type="button" value="查看" class="mybutton myblue" onclick="

		var checkboxStr=document.getElementsByName('labels');
		var check_labels = '';
	    for(var i=0; i<checkboxStr.length; i++){  
	        if(checkboxStr[i].checked){  
	            check_labels += checkboxStr[i].value + '/';
	         }
	     }
      
	    var a=document.getElementById('ljump');
	    a.href+='&labels='+check_labels;
	    

"/></a>
</div>

 
 <%

		sql0="select artid,label from article_labels";
		db0=new DBManager(sql0);
		Map<String,String> art_labels = new HashMap<>();
		rs0 = db0.pst.executeQuery();
		while(rs0.next())
		{
			art_labels.put(rs0.getString(1), rs0.getString(2));
		}
		rs0.close();
		db0.close();
 	

	  
	   String sql=null;
	   if(type==null || type.equals("null"))
	   		sql="select * from articles";
	   	else if(type.equals("report"))
	   		sql="select * from articles where type='report'";
	   	else
	   		sql="select * from articles where type='other'";
	   	
	   	String labels = request.getParameter("labels");
	   	ArrayList<String> search_labels = new ArrayList<>();
	   	if(labels != null)
	   	{
	   		for(String s:labels.split("/"))
	   		{
	   			if(!s.equals(""))
	   				search_labels.add(s);
	   		}
	   	}
	   	
	   	sql+=" order by time desc";
       DBManager db=new DBManager(sql);
       ArrayList<Article> needs = new ArrayList<Article>();
       ResultSet rs=db.pst.executeQuery();
       while(rs.next())
       {
       		String al = art_labels.get(rs.getString("id"));
     		Article article = new Article();
            article.setId(rs.getString("id"));
            article.setTitle(rs.getString("title"));
            article.setAuthor(rs.getString("author"));
            article.setTime(rs.getDate("time"));
            article.setType(rs.getString("type"));
            article.setLabels(al);
       		
       		if(labels != null && search_labels.size() > 0)
       		{//按标签搜索
       			if(al != null)
       			{
       				boolean is = true;
       				ArrayList<String> arr_al = new ArrayList<>(Arrays.asList(al.split("/")));
       				
		       		for(String s:search_labels)
		       		{
		       			if(!arr_al.contains(s))
		       			{				           
				            is = false;
				            break;
		            	}
		            }
		            if(is)
		            {
		            	needs.add(article);
		            }
	            }
            }
            else
            {
            	needs.add(article);
            }
       }
       rs.close();
       db.close();
		

		String itemsPerPageString = request.getParameter("itemsPerPage");
		String currPageString = request.getParameter("currPage");
		int currPage=1;
		if(currPageString==null)currPageString="1";
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
    <td class="resourceNameClass">
  
  	<div>
    <wiki:LinkTo page="<%=String.valueOf(art.getId()) %>">
		<%=sname %>
	</wiki:LinkTo>
	</div>
	<div>
	<a class="resourceListType" href="<%=goPage %>&type=<%=art.getType() %> ">[<%=m.get(art.getType()) %>]</a>
	
	
	<%
	for(String s:art.getLabels().split("/"))
	{
		if(!s.equals(""))
		{
	 %>
	 <a class="resourceListType" href="<%=goPage %>&type=<%=art.getType() %>&labels=<%=s %> ">[<%=s %>]</a>
	 <%
	 	}
	 }
	  %>
	
	
	</div>
	</td>
    <td class="table_center"><a href="CheckHomepageExist.jsp?fullName=<%=art.getAuthor() %>"><%=art.getAuthor() %></a> </td>
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
  <a href="<%=goPage %>&type=<%=type %>&currPage=<%=currPage-1 %>">
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
             <a href="<%=goPage %>&type=<%=type %>&currPage=<%=p %>" >
                <input type="button" value="<%=p %>" class="pageButton myblue"/>
             </a>
  <%
            }else{
   %>
              <a href="<%=goPage %>&type=<%=type %>&currPage=<%=p %>"  >
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
  <a href="<%=goPage %>&type=<%=type %>&currPage=<%=currPage+1 %>">
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


<!-- 直接跳转 -->
共<%=totalPage %>页 -向<input type="text" id="jumpToText" value="<%=currPage %>" size="2" />页 
<a href="<%=goPage %>&type=<%=type %>&currPage= " id="jumpToLink">
 <input type="button" value="跳转" class="mybutton myblue" onclick="


        var page = document.getElementById('jumpToText').value;
	    var a=document.getElementById('jumpToLink');
	    if(!(Math.floor(page) == page) || page > <%=totalPage %> || page < 1 ){
	        alert('没有该页')
	        a.href='';
	       
	    }else{
	          a.href+=page;
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
 

</div>