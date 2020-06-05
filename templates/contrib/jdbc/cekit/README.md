# JBoss KIE JDBC Driver Extension Images - CeKIT

## Before you begin

To interact with this repo you should install the CEKit 3.2.0:

#### Installing and Configure CeKit
In this section you'll , step by step, how to install CeKit on Fedora, for other systems please refer to the documentation: 
To be possible to install the CeKit using dnf, we need to enable it's dnf repository:

Install [CeKit](https://docs.cekit.io/en/latest/handbook/installation/instructions.html#other-systems) 3.2 using virtualenv: 

To install, see the following commands:

```bash
$ mkdir ~/cekit-3.2
$ vritualenv ~/cekit-3.2
$ source ~/cekit-3.2/bin/activate # tip create an alias for it, e.g. activate-cekit-3.2
$ pip install cekit==3.2.0 
$ pip install odcs docker docker-squash behave
```


## Building an extension image

After you have installed CeKit, all you need to do is execute ```make``` passing
as parameter the desired option, press `tab` for auto completion, see the example below: 

```bash
make mysql
```

This command will build the mysql extension image with the jdbc driver version 8.0.12.

The artifacts to build the db2, mysql, mariadb, postgresql and mssql are available on maven central.

See the examples below on how to build the other extension images:

If you want to specify a custom artifact, use the *artifact* and *version* variables within make command:

```bash
make db2 artifact=/tmp/db2-jdbc-driver.jar version=10.1
```

### Build MySQL

```bash
make mysql
```

### Build MariaDB

```bash
make mariadb
```

### Build PostgreSQL

```bash
make postgresql
```

### Build MS SQL

```bash
make mssql
```

### Build Oracle DB

Oracle extension image requires you to provide the jdbc jar:

```bash
make oracle artifact=/tmp/ojdbc7.jar version=7.0
```

### Build DB2

DB2 extension image requires you to provide the jdbc jar:

```bash
make db2 artifact=/tmp/db2jcc4.jar version=10.2
```

### Build Sybase

Sybase extension image requires you to provide the jdbc jar:

```bash
make sybase artifact=/tmp/jconn4-16.0_PL05.jar version=16.0_PL05
```

If for you need to update the driver xa class or driver class export the `DRIVER_CLASS` or `DRIVER_XA_CLASS` environment
with the desired class, e.g.:

```bash
export DRIVER_CLASS=another.class.Sybase && make sybase artifact=/tmp/jconn4-16.0_PL05.jar version=16.0_PL0
```

After you build your extension image you can:

- Push the image to some internal/public registry and import the image on OpenShift using:
  - imagestream:

      ```yaml
        ---
        kind: List
        apiVersion: v1
        metadata:
          name: jboss-kie-jdbc-extensions-image
          annotations:
            description: ImageStream definition for jdbc driver extension
        items:
        - kind: ImageStream
          apiVersion: v1
          metadata:
            name: jboss-kie-oracle-extension-openshift-image
            annotations:
              openshift.io/display-name: oracle driver extension
          spec:
            dockerImageRepository: some.public.registry/projectname/jboss-kie-oracle-extension-openshift-image
            tags:
            - name: '12cR1'
              annotations:
                description: JBoss KIE custom mysql jdbc extension image, recommended version driver.
                tags: oracle,extension,jdbc,driver
                version: '12cR1'
      ```

      then import it on OpenShift:

      ```bash
      oc create -f my-image-stream.yaml
      ```

  - import directly on OpenShift:

      ```bash
      oc import-image jboss-kie-oracle-extension-openshift-image:12cR1 --from=registry/project/jboss-kie-oracle-extension-openshift-image:12cR1 --confirm
      ```

  - push the image directly to the OpenShift registry: [Accessing the registry](https://docs.openshift.com/container-platform/3.11/install_config/registry/accessing_registry.html#access)


If you find any issue feel free to drop an email to bsig-cloud@redhat.com or fill an [issue](https://issues.jboss.org/projects/RHPAM)
