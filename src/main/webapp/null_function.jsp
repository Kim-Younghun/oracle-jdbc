<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%> 
<%
	//DB연결
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@127.0.0.1:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn+"접속성공");
	// 초기화
	PreparedStatement nvlStmt = null;
	PreparedStatement nvl2Stmt = null;
	PreparedStatement nullifStmt = null;
	PreparedStatement coalesceStmt = null;
	ResultSet nvlRs = null;
	ResultSet nvl2Rs = null;
	ResultSet nullifRs = null;
	ResultSet coalesceRs = null;
	
	/*
		select 이름, nvl(일분기, 0) nvl from 실적;
	*/
	
	String nvlSql = "select 이름, nvl(일분기, 0) nvl from 실적";
	nvlStmt = conn.prepareStatement(nvlSql);
	System.out.println(nvlStmt);
	nvlRs = nvlStmt.executeQuery();
	ArrayList<HashMap<String, Object>> nvlList = new ArrayList<>();
	while(nvlRs.next()) {
		HashMap<String, Object> m = new HashMap<>();
		m.put("이름", nvlRs.getString("이름"));
		m.put("nvl", nvlRs.getString("nvl"));
		nvlList.add(m);
	}
	System.out.println(nvlList);
	
	/*
		select 이름, nvl2(일분기, 'success', 'fail') nvl2 from 실적;
	*/
	
	String nvl2Sql = "select 이름, nvl2(일분기, 'success', 'fail') nvl2 from 실적";
	nvl2Stmt = conn.prepareStatement(nvl2Sql);
	System.out.println(nvl2Stmt);
	nvl2Rs = nvl2Stmt.executeQuery();
	ArrayList<HashMap<String, Object>> nvl2List = new ArrayList<>();
	while(nvl2Rs.next()) {
		HashMap<String, Object> m2 = new HashMap<>();
		m2.put("이름", nvl2Rs.getString("이름"));
		m2.put("nvl2", nvl2Rs.getString("nvl2"));
		nvl2List.add(m2);
	}
	System.out.println(nvl2List);
	
	/*
		select 이름, nullif(사분기, to_char(100)) nullif from 실적
	*/
	
	String nullifSql = "select 이름, nullif(사분기, to_char(100)) nullif from 실적";
	nullifStmt = conn.prepareStatement(nullifSql);
	System.out.println(nullifStmt);
	nullifRs = nullifStmt.executeQuery();
	ArrayList<HashMap<String, Object>> nullifList = new ArrayList<>();
	while(nullifRs.next()) {
		HashMap<String, Object> m3 = new HashMap<>();
		m3.put("이름", nullifRs.getString("이름"));
		m3.put("nullif", nullifRs.getInt("nullif"));
		nullifList.add(m3);
	}
	System.out.println(nullifList);
	
	/*
		select 이름, coalesce(일분기, 이분기, 삼분기, 사분기) coalesce from 실적
	*/
	
	String coalesceSql = "select 이름, coalesce(일분기, 이분기, 삼분기, 사분기) coalesce from 실적";
	coalesceStmt = conn.prepareStatement(coalesceSql);
	System.out.println(coalesceStmt);
	coalesceRs = coalesceStmt.executeQuery();
	ArrayList<HashMap<String, Object>> coalesceList = new ArrayList<>();
	while(coalesceRs.next()) {
		HashMap<String, Object> m4 = new HashMap<>();
		m4.put("이름", coalesceRs.getString("이름"));
		m4.put("coalesce", coalesceRs.getString("coalesce"));
		coalesceList.add(m4);
	}
	System.out.println(coalesceList);
%>   
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h1>실적 table nvl test</h1>
	<table border="1">
		<tr>
			<td>이름</td>
			<td>nvl(일분기, 0)</td>
		</tr>
		<%
			for(HashMap<String, Object> m : nvlList) {
		%>
		<tr>
			<td><%=(m.get("이름"))%></td>
			<td><%=(m.get("nvl"))%></td>
		</tr>
		<%
			}
		%>
	</table>
	<br>
	<h1>실적 table nvl2 test</h1>
	<table border="1">
		<tr>
			<td>이름</td>
			<td>nvl2(일분기, 'success', 'fail')</td>
		</tr>
		<%
			for(HashMap<String, Object> m2 : nvl2List) {
		%>
		<tr>
			<td><%=(m2.get("이름"))%></td>
			<td><%=(m2.get("nvl2"))%></td>
		</tr>
		<%
			}
		%>
	</table>
	<br>
	<h1>실적 table nvllif test</h1>
	<table border="1">
		<tr>
			<td>이름</td>
			<td>nullif(사분기, to_char(100))</td>
		</tr>
		<%
			for(HashMap<String, Object> m3 : nullifList) {
		%>
		<tr>
			<td><%=(m3.get("이름"))%></td>
			<td><%=(Integer)(m3.get("nullif"))%></td>
		</tr>
		<%
			}
		%>
	</table>
	<br>
	<h1>실적 table coalesce test</h1>
	<table border="1">
		<tr>
			<td>이름</td>
			<td>coalesce(일분기, 이분기, 삼분기, 사분기)</td>
		</tr>
		<%
			for(HashMap<String, Object> m4 : coalesceList) {
		%>
		<tr>
			<td><%=(m4.get("이름"))%></td>
			<td><%=(m4.get("coalesce"))%></td>
		</tr>
		<%
			}
		%>
	</table>
</body>
</html>