# Simple Cluster with ANSYS installed

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Ftanewill%2F5clickTemplates%2Fmaster%2FRawANSYSCluster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png" />
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Ftanewill%2F5clickTemplates%2Fmaster%2FRawANSYSCluster%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>
<br></br>
<b>Quickstart</b>

	1) Deploy ARM Template
		a. Click on the link above
		b. Select HPC available region
		c. Select vm size (H16m/H16mr or A8/A9) and quantity (make sure to have quota for it)
		d. Name, less than 10 characters
		e. License server IP, use default if in MSFT
		f. Benchmark model
	2) Wait for deployment (may be long if a larger model)
	3) Logon to machine IP listed in portal
	4) Navigate to /mnt/resource
	5) configure VPN
	6) Run fluent, t20 is the number of cores you want to run on
		a. time(fluent 3d -g -mpi=intel -pib.dapl -mpiopt="-genv I_MPI_DAPL_PROVIDER=ofa-v2-ib0" -ssh -t20 -cnf=hosts -i runme.jou)


<b>Architecture</b>

<img src="https://github.com/tanewill/5clickTemplates/blob/master/images/hpc_vmss_architecture.png"  align="middle" width="395" height="274"  alt="hpc_vmss_architecture" border="1"/> <br></br>
This template is designed to assist in the assessment of the ANSYS Fluent CFD package in the Microsoft Azure environment. It automatically downloads and configures Fluent. In addition it authenticates all of the nodes on the cluster and creates a common share directory to be used for each of the nodes. A Virtual Machine Jumpbox is created and a Virtual Machine Scale Set (VMSS) of the same type of machine is created. The VMSS enables easy scaling and quick deployment of the cluster. The Jumpbox serves as the head node. A network card is attached to the Jumpbox and placed in a Virtual Network. The Jumpbox and VMSS reside in the same virtual network. A public IP is assigned to the network with port 22 open. The Jumpbox can be accessed with the following command:

<code>ssh {username}@{vm-private-ip-address}</code>

Four Storage Accounts are created for the VMSS and one for the Jumpbox. An NFS file share is created from the head node's OS disk and shared with all of the VMSS nodes. This NFS share is located at /mnt/nfsshare/ No other file sharing or server is used. The Jumpbox and each of the nodes in the VMSS also have a data disk mounted at /mnt/resource/ that provides local storage space.


<b>Software Configuration</b>

A number of packages are installed during deployment in order to support the NFS share and the tools that are used to create the authentication. During the authentication phase of the deployment, files named <u>nodenames.txt</u> and <u>nodeips.txt</u> are placed in ~/bin. These are files that contain the names and ip addresses of all of the nodes in the VMSS a copy of the <u>nodenames.txt</u> is placed in <u>/mnt/resource/hosts</u>. Each of these nodes should be accesible with the following command:

<code>ssh {username}@{vm-private-ip-address}</code>

In addition ANSYS Fluent version 17.2 is installed into the <u>/mnt/nfsshare/</u> directory and the path to the Fluent binary is added to ~.bashrc. The benchmark model that was selected at deploy time is downloaded and unpacked as <u>benchmark.cas.tgz</u> and <u>benchmark.dat.tgz</u> these are the 'Case' and 'Data' files for Fluent. They are placed in /mnt/resource on the Jumpbox. A file named runme.jou contains the scripting commands for Fluent. With these three files a benchmark can be run by issuing the following command.

<code>time(fluent 3d -g -mpi=intel -pib.dapl -mpiopt="-genv I_MPI_DAPL_PROVIDER=ofa-v2-ib0" -ssh -t48 -cnf=hosts -i runme.jou)</code>

<b>Licensing</b>

Currently the default settings point to an internal Microsoft ANSYS license that can only be used for benchmarking, performance testing, and other non-sales related activities. If you are using this as part of a sales process you will need to simply place the IP address of the ANSYS license server in as a parameter at deploy time.

We have updated this to use a VPN, please contact tanewill@microsoft.com for information regarding how to use the ANSYS license.

<b>Known Issues</b>

The Jumpbox takes the name given in the vmssName parameter and appends a 'jb' for its hostname. It is a known bug that Fluent will not properly communicate with the license server if the hostname is longer than 12 characters. The vmssName parameter is limited to 10 characters for that reason. H-Series VMs are only available in the South Central region, A8 and A9 VMs are only available in East US, North Central US, South Central US, West US, North Europe, West Europe, and Japan East.
