<%@page import="java.util.HashSet"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.ArrayList"%>
<%@ page language="java" pageEncoding="UTF-8"%>  
 <%@page import="java.sql.ResultSet"%>
<%@page import="dr.DBManager"%>
  <%
   String pageId = request.getParameter("page");
   if(pageId.getBytes()[0]=='2')  //文章页id头字符为2，资源页id头为1
   {
   		String sql="select title,type from articles where id=?";
   		DBManager db=new DBManager(sql);
   		db.pst.setString(1, pageId);
   		ResultSet rs=db.pst.executeQuery();
   		String title="";
   		String type=null;
   		if(rs.next())
   		{
   			title=rs.getString("title");
   			type=rs.getString("type");
   		}
   	    rs.close();
   	    db.close();
    %>  

     <div>
	<label>标题：</label>
	<input class="form-control form-col-50" value="<%=title %>" name="article_title" id="article_title" type="text" maxlength="200" size="200"/>
	<br/>
	<label>类型：</label>
	<select class="form-control form-col-20" name="article_type" id="type_select">
			<option value="report">读书报告</option>
			<option value="other">其他</option>
	</select>
	<br/>
	<label>标签：</label>
	<div>
<%
		sql="select label from labels";
   		db=new DBManager(sql);
   		ArrayList<String> labels = new ArrayList<>();
   		rs = db.pst.executeQuery();
   		while(rs.next())
   		{
   			labels.add(rs.getString(1));
   		}
   		rs.close();
   	    db.close();
   	    
   	    Set<String> check_labels = new HashSet<>();
   	    sql="select label from article_labels where artid=?";
   		db=new DBManager(sql);
   		db.pst.setString(1, pageId);
   		rs = db.pst.executeQuery();
   		while(rs.next())
   		{
   			for(String s:rs.getString(1).split("/"))
   			{
   				check_labels.add(s);
   			}
   		}
   		rs.close();
   	    db.close();
   	    
   	    for(String s:labels)
   	    {
   	    	if(check_labels.contains(s))
   	    	{
 %>
		<label><input name="labels" type="checkbox" value="<%=s %>" checked=true /><%=s %></label>&nbsp
<%
			}
			else{
 %>
 		<label><input name="labels" type="checkbox" value="<%=s %>" /><%=s %></label>
 <%
		 	}
		 }
  %>
  		<br/>
 		
		<label>自定义标签(多个标签以‘/’隔开)：</label>
		<input class="form-control form-col-20"  name="custom_label" id="custom_label" type="text" maxlength="200" size="200"/>
 		
	</div>
	</div>
	
 <script  type = "text/javascript" >
function change(){

	var t="<%=type %>";
	var select=document.getElementById("type_select");
	
    for(var i=0;i<select.options.length;i++)
    {
        if(select.options[i].value ==t )
        {
            select.options[i].selected=true;
            break;
        }
    }
    
    var submit=document.getElementById("editor_submit");
 //   alert(submit);
 submit.onclick=function()
 {
	var article_title = document.getElementById("article_title").value;
	var editorarea = document.getElementById("editorarea").value;
	var checkboxStr=document.getElementsByName("labels");
	var custom_labels = document.getElementById("custom_label").value.split("/");
	
	var input  = /^[\s]*$/;
	if(input.test(article_title))
	{
		alert("请输入标题！");
    	return false;
    }
    if(input.test(editorarea))
	{
		alert("请输入内容！");
    	return false;
    }
    var islabel = false;
    for(var i=0; i<checkboxStr.length; i++){  
        if(checkboxStr[i].checked){  
            islabel = true;
            break;
         }
     }
     if(custom_labels.length == 0)
     {
     	islabel = false;
     }
     if(islabel == false)
     {
     	//alert("请输入标签！");
    	//return false;
     }
 }
}
window.onload=change;
</script > 
	
    <%
    }
     %>
     <br/>
     