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
	PreparedStatement GroupingSetStmt = null;
	PreparedStatement RollupStmt = null;
	PreparedStatement CubeStmt = null;
	ResultSet GroupingSetRs = null;
	ResultSet RollupRs = null;
	ResultSet CubeRs = null;
	
	/* 
		SELECT department_id, job_id, count(*) FROM employees
		GROUP BY GROUPING SETS(department_id, job_id)
	*/
	
	String GroupingSetSql = "SELECT department_id, job_id, count(*) FROM employees GROUP BY GROUPING SETS(department_id, job_id)";
	GroupingSetStmt = conn.prepareStatement(GroupingSetSql);
	System.out.println(GroupingSetStmt);
	GroupingSetRs = GroupingSetStmt.executeQuery();
	ArrayList<HashMap<String, Object>> GroupingSetList = new ArrayList<>();
	while(GroupingSetRs.next()) {
		HashMap<String, Object> m = new HashMap<>();
		m.put("department_id", GroupingSetRs.getString("department_id"));
		m.put("job_id", GroupingSetRs.getString("job_id"));
		m.put("count(*)", GroupingSetRs.getInt("count(*)"));
		GroupingSetList.add(m);
	}
	System.out.println(GroupingSetList);
	
	/*
		SELECT department_id, job_id, count(*) FROM employees
		GROUP BY ROLLUP(department_id, job_id)
	*/
	
	String RollupSql = "SELECT department_id, job_id, count(*) FROM employees GROUP BY ROLLUP(department_id, job_id)";
	RollupStmt = conn.prepareStatement(RollupSql);
	System.out.println(RollupStmt);
	RollupRs = RollupStmt.executeQuery();
	ArrayList<HashMap<String, Object>> RollupList = new ArrayList<>();
	while(RollupRs.next()) {
		HashMap<String, Object> m2 = new HashMap<>();
		m2.put("department_id", RollupRs.getString("department_id"));
		m2.put("job_id", RollupRs.getString("job_id"));
		m2.put("count(*)", RollupRs.getInt("count(*)"));
		RollupList.add(m2);
	}
	System.out.println(RollupList);
	
	/*
		SELECT department_id, job_id, count(*) 부서별인원 FROM employees
		GROUP BY CUBE(department_id, job_id)
	*/
	
	String CubeSql = "SELECT department_id, job_id, count(*) FROM employees GROUP BY CUBE(department_id, job_id)";
	CubeStmt = conn.prepareStatement(CubeSql);
	System.out.println(CubeStmt);
	CubeRs = CubeStmt.executeQuery();
	ArrayList<HashMap<String, Object>> CubeList = new ArrayList<>();
	while(CubeRs.next()) {
		HashMap<String, Object> m3 = new HashMap<>();
		m3.put("department_id", CubeRs.getString("department_id"));
		m3.put("job_id", CubeRs.getString("job_id"));
		m3.put("count(*)", CubeRs.getInt("count(*)"));
		CubeList.add(m3);
	}
	System.out.println(CubeList);
%>  
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h1>Employees table GROUP BY GroupingSet test</h1>
	<table border="1">
		<tr>
			<td>부서ID</td>
			<td>직무ID</td>
			<td>총인원</td>
		</tr>
		<%
			for(HashMap<String, Object> m : GroupingSetList) {
		%>
		<tr>
			<td><%=(m.get("department_id"))%></td>
			<td><%=(m.get("job_id"))%></td>
			<td><%=(Integer)(m.get("count(*)"))%></td>
		</tr>
		<%
			}
		%>
	</table>
	<br>
	<h1>Employees table GROUP BY Rollup test</h1>
	<table border="1">
		<tr>
			<td>부서ID</td>
			<td>직무ID</td>
			<td>총인원</td>
		</tr>
		<%
			for(HashMap<String, Object> m2 : RollupList) {
		%>
		<tr>
			<td><%=(m2.get("department_id"))%></td>
			<td><%=(m2.get("job_id"))%></td>
			<td><%=(Integer)(m2.get("count(*)"))%></td>
		</tr>
		<%
			}
		%>
	</table>
	<br>
	<h1>Employees table GROUP BY CUBE test</h1>
	<table border="1">
		<tr>
			<td>부서ID</td>
			<td>직무ID</td>
			<td>총인원</td>
		</tr>
		<%
			for(HashMap<String, Object> m3 : CubeList) {
		%>
		<tr>
			<td><%=(m3.get("department_id"))%></td>
			<td><%=(m3.get("job_id"))%></td>
			<td><%=(Integer)(m3.get("count(*)"))%></td>
		</tr>
		<%
			}
		%>
	</table>
</body>
</html>