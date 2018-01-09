package servlet;

import java.io.Serializable;
import java.util.Date;

public class ResourceInfo implements Serializable
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String ID;
	private String name;
	private String title;
	private long   size;
	private Date   time;
	private String type;
	private String author;
	
	
	
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
	public String getAuthor()
	{
		return author;
	}
	public void setAuthor(String author)
	{
		this.author = author;
	}
	
	
	public long getSize()
	{
		return size;
	}
	public void setSize(long size)
	{
		this.size = size;
	}
	public String getID()
	{
		return ID;
	}
	public void setID(String iD)
	{
		ID = iD;
	}
	public String getName()
	{
		return name;
	}
	public void setName(String name)
	{
		this.name = name;
	}
	public String getTitle()
	{
		return title;
	}
	public void setTitle(String title)
	{
		this.title = title;
	}

}
