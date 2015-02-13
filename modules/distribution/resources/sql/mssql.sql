IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_OAUTH_CONSUMER_APPS]') AND TYPE IN (N'U'))

CREATE TABLE IDN_OAUTH_CONSUMER_APPS (
            CONSUMER_KEY VARCHAR(255),
            CONSUMER_SECRET VARCHAR(512),
            USERNAME VARCHAR(255),
            TENANT_ID INTEGER DEFAULT 0,
            APP_NAME VARCHAR(255),
            OAUTH_VERSION VARCHAR(128),
            CALLBACK_URL VARCHAR(1024),
            LOGIN_PAGE_URL VARCHAR (1024),
            ERROR_PAGE_URL VARCHAR (1024),
            CONSENT_PAGE_URL VARCHAR (1024),
            GRANT_TYPES VARCHAR(1024),
            PRIMARY KEY (CONSUMER_KEY)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_SUBSCRIBER]') AND TYPE IN (N'U'))

CREATE TABLE AM_SUBSCRIBER (
    SUBSCRIBER_ID INTEGER IDENTITY(1,1),
    USER_ID VARCHAR(50) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    EMAIL_ADDRESS VARCHAR(256) NULL,
    DATE_SUBSCRIBED DATETIME NOT NULL,
    PRIMARY KEY (SUBSCRIBER_ID),
    UNIQUE (TENANT_ID,USER_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_APPLICATION]') AND TYPE IN (N'U'))

CREATE TABLE AM_APPLICATION (
    APPLICATION_ID INTEGER IDENTITY(1,1),
    NAME VARCHAR(100),
    SUBSCRIBER_ID INTEGER,
    APPLICATION_TIER VARCHAR(50) DEFAULT 'Unlimited',
    CALLBACK_URL VARCHAR(512),
    DESCRIPTION VARCHAR(512),
	APPLICATION_STATUS VARCHAR(50) DEFAULT 'APPROVED',
    FOREIGN KEY(SUBSCRIBER_ID) REFERENCES AM_SUBSCRIBER(SUBSCRIBER_ID) ON UPDATE CASCADE,
    PRIMARY KEY(APPLICATION_ID),
    UNIQUE (NAME,SUBSCRIBER_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[APPMGR_APP]') AND TYPE IN (N'U'))

CREATE TABLE APPMGR_APP (
    API_ID INTEGER IDENTITY(1,1),
    API_PROVIDER VARCHAR(200),
    API_NAME VARCHAR(200),
    API_VERSION VARCHAR(30),
    CONTEXT VARCHAR(256),
    TRACKING_CODE varchar(100),
    UUID varchar(500),
    LOG_OUT_URL varchar(500),
    APP_ALLOW_ANONYMOUS BOOLEAN NULL,
    PRIMARY KEY(API_ID),
    UNIQUE (API_PROVIDER,API_NAME,API_VERSION)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[APM_POLICY_GROUP]') AND TYPE IN (N'U'))

CREATE TABLE APM_POLICY_GROUP
( 
	POLICY_GRP_ID INTEGER AUTO_INCREMENT,
	NAME VARCHAR(256),
	AUTH_SCHEME VARCHAR(50) NULL,
	THROTTLING_TIER varchar(512) DEFAULT NULL,
	USER_ROLES varchar(512) DEFAULT NULL,  
	URL_ALLOW_ANONYMOUS BOOLEAN DEFAULT FALSE,   
	PRIMARY KEY (POLICY_GRP_ID)
);
 
IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[APM_POLICY_GROUP_MAPPING]') AND TYPE IN (N'U'))

CREATE TABLE APM_POLICY_GROUP_MAPPING
( 
    URL_MAPPING_ID INTEGER AUTO_INCREMENT,
    APP_ID INTEGER NOT NULL,
    HTTP_METHOD VARCHAR(20) NULL,
	URL_PATTERN VARCHAR(512) NULL, 
    SKIP_THROTTLING BOOLEAN DEFAULT FALSE,  
    POLICY_GRP_ID INTEGER NULL,
    FOREIGN KEY(APP_ID) REFERENCES APM_APP(APP_ID) ON UPDATE CASCADE,
    FOREIGN KEY (POLICY_GRP_ID) REFERENCES APM_POLICY_GROUP (POLICY_GRP_ID),
    PRIMARY KEY(URL_MAPPING_ID)
);


IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[APPMGR_APP_URL_MAPPING]') AND TYPE IN (N'U'))

CREATE TABLE APPMGR_APP_URL_MAPPING (
    URL_MAPPING_ID INTEGER AUTO_INCREMENT,
    APP_ID INTEGER NOT NULL,
    HTTP_METHOD VARCHAR(20) NULL,
	URL_PATTERN VARCHAR(512) NULL, 
    SKIP_THROTTLING BOOLEAN DEFAULT FALSE,  
    POLICY_GRP_ID INTEGER NULL,
    FOREIGN KEY(APP_ID) REFERENCES APM_APP(APP_ID) ON UPDATE CASCADE,
    FOREIGN KEY (POLICY_GRP_ID) REFERENCES APM_POLICY_GROUP (POLICY_GRP_ID),
    PRIMARY KEY(URL_MAPPING_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_SUBSCRIPTION]') AND TYPE IN (N'U'))

CREATE TABLE AM_SUBSCRIPTION (
    SUBSCRIPTION_ID INTEGER IDENTITY(1,1),
    SUBSCRIPTION_TYPE VARCHAR(50),
    TIER_ID VARCHAR(50),
    API_ID INTEGER,
    LAST_ACCESSED DATETIME NULL,
    APPLICATION_ID INTEGER,
    SUB_STATUS VARCHAR(50),
    FOREIGN KEY(APPLICATION_ID) REFERENCES AM_APPLICATION(APPLICATION_ID) ON UPDATE CASCADE,
    FOREIGN KEY(API_ID) REFERENCES APPMGR_APP(API_ID) ON UPDATE CASCADE,
    PRIMARY KEY (SUBSCRIPTION_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_SUBSCRIPTION_KEY_MAPPING]') AND TYPE IN (N'U'))

CREATE TABLE AM_SUBSCRIPTION_KEY_MAPPING (
    SUBSCRIPTION_ID INTEGER,
    ACCESS_TOKEN VARCHAR(255),
    KEY_TYPE VARCHAR(512) NOT NULL,
    FOREIGN KEY(SUBSCRIPTION_ID) REFERENCES AM_SUBSCRIPTION(SUBSCRIPTION_ID) ON UPDATE CASCADE,
    PRIMARY KEY(SUBSCRIPTION_ID,ACCESS_TOKEN)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_APPLICATION_KEY_MAPPING]') AND TYPE IN (N'U'))

CREATE TABLE AM_APPLICATION_KEY_MAPPING (
    APPLICATION_ID INTEGER,
    CONSUMER_KEY VARCHAR(255),
    KEY_TYPE VARCHAR(512) NOT NULL,
    FOREIGN KEY(APPLICATION_ID) REFERENCES AM_APPLICATION(APPLICATION_ID) ON UPDATE CASCADE,
    PRIMARY KEY(APPLICATION_ID,CONSUMER_KEY)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[APPMGR_APP_LC_EVENT]') AND TYPE IN (N'U'))

CREATE TABLE APPMGR_APP_LC_EVENT (
    EVENT_ID INTEGER IDENTITY(1,1),
    API_ID INTEGER NOT NULL,
    PREVIOUS_STATE VARCHAR(50),
    NEW_STATE VARCHAR(50) NOT NULL,
    USER_ID VARCHAR(50) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    EVENT_DATE DATETIME NOT NULL,
    FOREIGN KEY(API_ID) REFERENCES APPMGR_APP(API_ID) ON UPDATE CASCADE,
    PRIMARY KEY (EVENT_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_APP_KEY_DOMAIN_MAPPING]') AND TYPE IN (N'U'))

CREATE TABLE AM_APP_KEY_DOMAIN_MAPPING (
   CONSUMER_KEY VARCHAR(255),
   AUTHZ_DOMAIN VARCHAR(255) DEFAULT 'ALL',
   PRIMARY KEY (CONSUMER_KEY,AUTHZ_DOMAIN),
   FOREIGN KEY (CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[APPMGR_APP_COMMENTS]') AND TYPE IN (N'U'))

CREATE TABLE APPMGR_APP_COMMENTS (
    COMMENT_ID INTEGER IDENTITY(1,1),
    COMMENT_TEXT VARCHAR(512),
    COMMENTED_USER VARCHAR(255),
    DATE_COMMENTED DATETIME NOT NULL,
    API_ID INTEGER NOT NULL,
    FOREIGN KEY(API_ID) REFERENCES APPMGR_APP(API_ID) ON UPDATE CASCADE,
    PRIMARY KEY (COMMENT_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[APPMGR_APP_RATINGS]') AND TYPE IN (N'U'))

CREATE TABLE APPMGR_APP_RATINGS (
    RATING_ID INTEGER IDENTITY(1,1),
    API_ID INTEGER,
    RATING INTEGER,
    SUBSCRIBER_ID INTEGER,
    FOREIGN KEY(API_ID) REFERENCES APPMGR_APP(API_ID) ON UPDATE CASCADE,
    FOREIGN KEY(SUBSCRIBER_ID) REFERENCES AM_SUBSCRIBER(SUBSCRIBER_ID) ON UPDATE CASCADE,
    PRIMARY KEY (RATING_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_TIER_PERMISSIONS]') AND TYPE IN (N'U'))

CREATE TABLE AM_TIER_PERMISSIONS (
    TIER_PERMISSIONS_ID INTEGER IDENTITY(1,1),
    TIER VARCHAR(50) NOT NULL,
    PERMISSIONS_TYPE VARCHAR(50) NOT NULL,
    ROLES VARCHAR(512) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    PRIMARY KEY(TIER_PERMISSIONS_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_EXTERNAL_STORES]') AND TYPE IN (N'U'))

CREATE TABLE AM_EXTERNAL_STORES (
    APISTORE_ID INTEGER IDENTITY(1,1),
    API_ID INTEGER,
    STORE_ID VARCHAR(255) NOT NULL,
    STORE_DISPLAY_NAME VARCHAR(255) NOT NULL,
    STORE_ENDPOINT VARCHAR(255) NOT NULL,
    STORE_TYPE VARCHAR(255) NOT NULL,
    FOREIGN KEY(API_ID) REFERENCES APPMGR_APP(API_ID) ON UPDATE CASCADE,
    PRIMARY KEY (API_ID)
);

CREATE TABLE AM_WORKFLOWS(
    WF_ID INTEGER IDENTITY(1,1),
    WF_REFERENCE VARCHAR(255) NOT NULL,
    WF_TYPE VARCHAR(255) NOT NULL,
    WF_STATUS VARCHAR(255) NOT NULL,
    WF_CREATED_TIME DATETIME,
    WF_UPDATED_TIME DATETIME,
    WF_STATUS_DESC VARCHAR(1000),
    TENANT_ID INTEGER,
    TENANT_DOMAIN VARCHAR(255),
    WF_EXTERNAL_REFERENCE VARCHAR(255) NOT NULL UNIQUE,
    PRIMARY KEY (WF_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[APPMGR_APP_HIT_TOTAL]') AND TYPE IN (N'U'))

CREATE TABLE IF NOT EXISTS APPMGR_APP_HIT_TOTAL (
UUID VARCHAR2(500) NOT NULL,
USER_ID VARCHAR2(50) NOT NULL,
HIT_COUNT BIGINT,
TENANT_ID INTEGER,
PRIMARY KEY (UUID, USER_ID),
FOREIGN KEY (UUID) REFERENCES APPMGR_APP(UUID),
FOREIGN KEY (USER_ID) REFERENCES AM_SUBSCRIBER(USER_ID)
); 

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[APM_APP_JAVA_POLICY]') AND TYPE IN (N'U'))

CREATE TABLE APM_APP_JAVA_POLICY
(
JAVA_POLICY_ID INTEGER AUTO_INCREMENT,
DISPLAY_NAME VARCHAR(100) NOT NULL,
FULL_QUALIFI_NAME VARCHAR(256) NOT NULL,
DESCRIPITON VARCHAR(2500),
ORDER_SEQ_NO INTEGER NOT NULL,
PRIMARY KEY(JAVA_POLICY_ID),
UNIQUE(FULL_QUALIFI_NAME,ORDER_SEQ_NO)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[APM_APP_JAVA_POLICY_MAPPING]') AND TYPE IN (N'U'))

CREATE TABLE APM_APP_JAVA_POLICY_MAPPING
(
JAVA_POLICY_ID INTEGER NOT NULL,
APP_ID  INTEGER NOT NULL,
FOREIGN KEY (JAVA_POLICY_ID) REFERENCES APM_APP_JAVA_POLICY(JAVA_POLICY_ID),
FOREIGN KEY (APP_ID) REFERENCES APM_APP(APP_ID) ON UPDATE CASCADE,
PRIMARY KEY (JAVA_POLICY_ID,APP_ID)
);

 
CREATE INDEX IDX_SUB_APP_ID ON AM_SUBSCRIPTION (APPLICATION_ID, SUBSCRIPTION_ID);
CREATE INDEX IDX_AT_CK_AU ON IDN_OAUTH2_ACCESS_TOKEN(CONSUMER_KEY, AUTHZ_USER, TOKEN_STATE, USER_TYPE);
