package servlet;

import java.io.Serializable;
import java.util.Date;
//import java.sql.Date;

public class Article implements Serializable
{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String id;
	private String title;
	private String author;
	private Date time;
	private String type;
	private String labels;
	
	public String getLabels()
	{
		return labels;
	}
	public void setLabels(String labels)
	{
		if (labels == null)
		{
			this.labels = "";
		}
		else {
			this.labels = labels;
		}
		
	}
	public String getId()
	{
		return id;
	}
	public void setId(String id)
	{
		this.id = id;
	}
	public String getTitle()
	{
		return title;
	}
	public void setTitle(String title)
	{
		this.title = title;
	}
	public String getAuthor()
	{
		return author;
	}
	public void setAuthor(String author)
	{
		this.author = author;
	}
	public Date getTime()
	{
		return time;
	}
	public void setTime(Date time)
	{
		this.time = time;
	}
	public String getType()
	{
		return type;
	}
	public void setType(String type)
	{
		this.type = type;
	}
	

}
