
<%@page import="org.apache.wiki.i18n.InternationalizationManager"%>
<%@page import="org.apache.wiki.auth.GroupPrincipal"%>
<%@page import="org.apache.wiki.preferences.Preferences"%>
<%@page import="java.security.Principal"%>
<%@page import="servlet.Paper"%>
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
<%!
     public String printGroups( WikiContext context )
    {
        Principal[] roles = context.getWikiSession().getRoles();
        List<String> tempRoles = new ArrayList<String>();
        ResourceBundle rb = Preferences.getBundle( context, InternationalizationManager.CORE_BUNDLE );
        
        for ( Principal role : roles )
        {
            if( role instanceof GroupPrincipal )
            {
                tempRoles.add( role.getName() );
            }
        }
        if ( tempRoles.size() == 0 )
        {
            return rb.getString("userprofile.nogroups");
        }

        StringBuilder sb = new StringBuilder();
        for ( int i = 0; i < tempRoles.size(); i++ )
        {
            String name = tempRoles.get( i );

            sb.append( name );
            if ( i < ( tempRoles.size() - 1 ) )
            {
                sb.append(',');
                sb.append(' ');
            }

        }
        return sb.toString();
    }
 %>
<%
String goPage="Home.jsp?tag=papers";

%>

<%
     WikiEngine wiki = WikiEngine.getInstance( getServletConfig() );
    // Create wiki context and check for authorization
     WikiContext wikiContext = wiki.createContext( request, WikiContext.ADMIN );
     String groups=printGroups(wikiContext);
  //   System.out.println("PreferenceContent.jsp:groups="+groups);
     if(groups ==null)groups="";
     String [] gs = groups.split(",");
     boolean isAdmin=false;
     for(String g:gs)
     {
         if(g.trim().equals("Admin"))
         {
            isAdmin=true;
            break;
         }
     }
     if(isAdmin)
     {
 %>
 
 
 <%
  String msg = request.getParameter("msg");
  if( msg!=null  )
  {
         
 %>
 <div class="error text-align-center  paper_block"><%=msg %></div>
 <%
  }   
  %>
  <div class="paper_block">
 <form action="<wiki:Link jsp='Add_delete_Paper.jsp' format='url'><wiki:Param name='op' value='delete'/></wiki:Link>"
      class="hidden"
        name="deletePaperForm" id="deletePaperForm"
      method="POST" accept-charset="UTF-8">
  <input type="hidden" name="id" value="${group.name}" />
  <input type="submit" name="ok"
   data-modal="+ .modal"
        value="删除" />
  <div class="modal">请确认是否删除此论文！</div>
</form>

<form action="<wiki:Link jsp='Add_delete_Paper.jsp' format='url'><wiki:Param name='op' value='add'/></wiki:Link>"
          id="editProfile"
       class="accordion"
      method="post" accept-charset="UTF-8">
<div class="accordion-close">
		<h3>添加论文</h3>
		<table>
			<tr>
				<td width="10%"><label>标题：</label></td>
				<td width="90%"><input class="form-control"   name="title" id="title" type="text" maxlength="300" size="200"/></td>
			</tr>
			<tr>
				<td><label>作者列表:<br/>(以“/”分割)</label></td>
				<td><input class="form-control "  name="authors" id="authors" type="text" maxlength="300" size="200"/></td>
			</tr>
			<tr>
				<td><label>关键词:<br/>(以“/”分割)</label></td>
				<td><input class="form-control "  name="keywords" id="keywords" type="text" maxlength="200" size="200"/></td>
			</tr>
			<tr>
				<td><label>发表信息：</label></td>
				<td><textarea class="form-control "  name="info" id="info" " maxlength="500" rows="3" cols="20" ></textarea></td>
			</tr>
			<tr>
				<td><label>摘要：</label></td>
				<td><textarea class="form-control "  name="abstract" id="abstract"  maxlength="3000" rows="20" cols="50" ></textarea></td>
			</tr>
			<tr>
				<td><label>备注:<br/>(可选)</label></td>
				<td><textarea class="form-control " name="custom_info" id="custom_info" maxlength="200" rows="4" cols="20"></textarea></td>
			</tr>
			<tr>
				<td></td>
				<td><div class="form-group">
				    <button class="btn btn-primary btn-block" type="submit" name="action" id="add_submit" value="saveProfile">
				      添加论文
				    </button>
			    </div>
			    </td>
			</tr>
		</table>
</div>
</form>
</div>
 
 <script type="text/javascript">
var submit=document.getElementById("add_submit");
 submit.onclick=function()
 {
 	var title = document.getElementById("title").value;
 	var authors = document.getElementById("authors").value;
 	var keywords = document.getElementById("keywords").value;
 	var info = document.getElementById("info").value;
 	var pp_abstract = document.getElementById("abstract").value;
 	
 	var input  = /^[\s]*$/;
	if(input.test(title))
	{
		alert("请输入标题！");
    	return false;
    }
    if(input.test(authors))
	{
		alert("请输入作者！");
    	return false;
    }
    /* if(input.test(keywords))
	{
		alert("请输入关键词！");
    	return false;
    } */
 /*    if(input.test(info))
	{
		alert("请输入发表信息！");
    	return false;
    } */
    if(input.test(pp_abstract))
	{
		alert("请输入摘要！");
    	return false;
    }
 }

//-->
</script>
<%
   }
 %>
 
<div class="papersList">

 
 <%
	   String sql="select * from papers";
	   	
       DBManager db=new DBManager(sql);
       ArrayList<Paper> needs = new ArrayList<Paper>();
       ResultSet rs=db.pst.executeQuery();
       while(rs.next())
       {
     		Paper paper = new Paper();
            paper.setId(rs.getString("id"));
            paper.setTitle(rs.getString("title"));
            paper.setAuthors(rs.getString("authors"));
            paper.setKeywords(rs.getString("keywords"));
            paper.setInfo(rs.getString("info"));
            paper.setCustom_info(rs.getString("custom_info"));
       		
       		needs.add(paper);
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
	 	
	 	ArrayList<Paper> shows = new ArrayList<Paper>();
		
		int index = itemsPerPage*(currPage-1);
		while (index<total && index<itemsPerPage*currPage)
		{
			shows.add(needs.get(index));
			index++;
		} 
		
		if(shows.size() ==0)
		{
 %>
   <div class="error text-align-center">没有论文</div>
 <%
        }else{
  %>
  
 <%
 	 if(isAdmin)
     {
      	for(Paper pp:shows)
	    {
	    StringBuilder asb = new StringBuilder();
	    for(String s:pp.getAuthors().split("/"))
	    	asb.append(s+", ");
	    StringBuilder ksb = new StringBuilder();
	    for(String s:pp.getKeywords().split("/"))
	    	ksb.append(s+"; ");
	   asb =  asb.delete(asb.length()-2,asb.length()-1);
	    ksb = ksb.delete(ksb.length()-2,ksb.length()-1);
 %>
 <div class="paper_block">
 <a href="Home.jsp?tag=viewpaper&id=<%=pp.getId() %>" >
<div class="paperinfo">
<p class="title"><%=pp.getTitle() %></p>
<p><%=asb %></p>
<p><%=ksb %></p>

</div>
</a>
<button class="btn btn-xs btn-danger" onclick="document.deletePaperForm.id.value ='<%=pp.getId() %>';document.deletePaperForm.ok.click();" >
          删除
</button>
<br/>
</div>
 
 <%
 		}
     }
     else
     {
	    for(Paper pp:shows)
	    {
	     StringBuilder asb = new StringBuilder();
	    for(String s:pp.getAuthors().split("/"))
	    {
	    	asb.append(s+", ");
	    }
	    StringBuilder ksb = new StringBuilder();
	    for(String s:pp.getKeywords().split("/"))
	    	ksb.append(s+"; ");
	    asb = asb.delete(asb.length()-2,asb.length()-1);
	    ksb = ksb.delete(ksb.length()-2,ksb.length()-1);
    
%>
<div class="paper_block">
<a href="Home.jsp?tag=viewpaper&id=<%=pp.getId() %>" >
<div class="paperinfo">
<p class="title"><%=pp.getTitle() %></p>
<p><%=asb %></p>
<p><%=ksb %></p>
</div>
</a>
</div>
<% 
   		}
    }
  %>
 

 




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
  <a href="<%=goPage %>&currPage=<%=currPage-1 %>">
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
             <a href="<%=goPage %>&currPage=<%=p %>" >
                <input type="button" value="<%=p %>" class="pageButton myblue"/>
             </a>
  <%
            }else{
   %>
              <a href="<%=goPage %>&currPage=<%=p %>"  >
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
  <a href="<%=goPage %>&currPage=<%=currPage+1 %>">
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
<a href="<%=goPage %>&currPage= " id="jumpToLink">
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