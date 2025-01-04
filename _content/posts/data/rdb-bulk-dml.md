---
draft: true
socialshare: true
date: 2024-12-16T13:00:00+09:00
lastmod: 2024-12-16T13:00:00+09:00
title: "Bulk DML - JDBC"
description: "MyBatis와 JPA"
featured_image: "/images/db/oracle-dbms-session-kibana.png"
images: ["/images/db/oracle-dbms-session-kibana.png"]
tags:
  - oracle
  - sql
categories:
  - wiki
---

# MyBatis

## Bulk Insert

```xml
<insert id="bulkInsertPlSql"
        parameterType="markruler.Employee">
    <foreach collection="list" item="vo" open= "begin" close= "; end;"  separator=";">
    INSERT INTO EMPLOYEE (name,
                          age,
                          address)
    VALUES (#{vo.name},
            #{vo.age},
            #{vo.address})
    </foreach>
</insert>
```

```xml
<insert id="bulkInsertUnionAll">
  INSERT INTO EMPLOYEE (NAME, AGE, ADDREESS)
  <foreach collection="list" item="vo" separator="UNION ALL">
    SELECT #{vo.name}, #{vo.age}, #{vo.address} FROM DUAL
  </foreach>
</insert>
```

## Bulk Update

```xml
<update id="bulkUpdatePlSql"
        parameterType="list">
    <foreach collection="list" item="vo" open= "begin" close= "; end;"  separator=";">
        UPDATE EMPLOYEE
        SET age = #{vo.age}
        WHERE name = #{vo.name}
    </foreach>
</update>
```

# JPA

- https://youtu.be/zMAX7g6rO_Y?t=1068
