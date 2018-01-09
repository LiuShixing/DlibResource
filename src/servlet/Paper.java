package servlet;

public class Paper
{
	private String id;
	private String title;
	private String authors;
	private String keywords;
	private String info;
	private String abstact;
	private String custom_info;
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
	public String getAuthors()
	{
		return authors;
	}
	public void setAuthors(String authors)
	{
		this.authors = authors;
	}
	public String getKeywords()
	{
		return keywords;
	}
	public void setKeywords(String keywords)
	{
		this.keywords = keywords;
	}
	public String getInfo()
	{
		return info;
	}
	public void setInfo(String info)
	{
		this.info = info;
	}
	public String getAbstact()
	{
		return abstact;
	}
	public void setAbstact(String abstact)
	{
		this.abstact = abstact;
	}
	public String getCustom_info()
	{
		return custom_info;
	}
	public void setCustom_info(String custom_info)
	{
		this.custom_info = custom_info;
	}

}
