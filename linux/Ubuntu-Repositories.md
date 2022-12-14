# What are Ubuntu Repositories? How to enable or disable them?  什么是 Ubuntu 存储库？ 如何启用或禁用它们？

This detailed article tells you about various repositories like universe, multiverse in Ubuntu and how to enable or disable them.  这篇详细的文章向您介绍了各种存储库，例如 Ubuntu 中的 Universe、Multiverse 以及如何启用或禁用它们。

So, you are trying to follow a tutorial from the web and installing a software [using apt-get command](https://itsfoss.com/apt-get-linux-guide/) and it throws you an error:  因此，您正在尝试遵循网络上的教程并使用 apt-get 命令安装软件，但它会引发错误：

```bash
E: Unable to locate package xyz
```

You are surprised because the package should be available. You search on the internet and come across a solution that you have to enable universe or multiverse repository to install that package.  您很惊讶，因为该软件包应该可用。 您在 Internet 上搜索并遇到一个解决方案，您必须启用 Universe 或 Multiverse 存储库才能安装该软件包。

You can enable universe and multiverse repositories in Ubuntu using the commands below:  您可以使用以下命令在 Ubuntu 中启用 Universe 和 Multiverse 存储库：

```bash
sudo add-apt-repository universe
sudo add-apt-repository multiverse
sudo apt update
```

You installed the universe and multiverse repository but do you know what are these repositories? How do they play a role in installing packages? Why are there several repositories?  您安装了 Universe 和 Multiverse 存储库，但您知道这些存储库是什么吗？ 他们如何在安装包中发挥作用？ 为什么有几个存储库？

I’ll explain all these questions in detail here.  我将在这里详细解释所有这些问题。

## The concept of repositories in Ubuntu  Ubuntu 中存储库的概念

Okay, so you already know that to [install software in Ubuntu](https://itsfoss.com/remove-install-software-ubuntu/), you can use the [apt command](https://itsfoss.com/apt-command-guide/). This is the same [APT package manager](https://wiki.debian.org/Apt) that Ubuntu Software Center utilizes underneath. So all the software (except Snap packages) that you see in the Software Center are basically from APT.  好的，所以您已经知道要在 Ubuntu 中安装软件，您可以使用 apt 命令。 这是 Ubuntu 软件中心在下面使用的同一个 APT 包管理器。 所以你在软件中心看到的所有软件（除了 Snap 包）基本上都是来自 APT。

Have you ever wondered where does the apt program install the programs from? How does it know which packages are available and which are not?  你有没有想过 apt 程序从哪里安装程序？ 它如何知道哪些包可用，哪些不可用？

Apt basically works on the repository. A repository is nothing but a server that contains a set of software. Ubuntu provides a set of repositories so that you won’t have to search on the internet for the installation file of various software of your need. This centralized way of providing software is one of the main strong points of using Linux.  Apt 基本上适用于存储库。 存储库只不过是包含一组软件的服务器。 Ubuntu 提供了一组存储库，这样您就不必在互联网上搜索您需要的各种软件的安装文件。 这种提供软件的集中方式是使用 Linux 的主要优势之一。

The APT package manager gets the repository information from the `/etc/apt/sources.list` file and files listed in `/etc/apt/sources.list.d` directory. Repository information is usually in the following format:  APT 包管理器从 /etc/apt/sources.list 文件和 /etc/apt/sources.list.d 目录中列出的文件获取存储库信息。 存储库信息通常采用以下格式：

```bash
deb http://us.archive.ubuntu.com/ubuntu/ bionic main
```

In fact, you can [go to the above server address](http://us.archive.ubuntu.com/ubuntu/) and see how the repository is structured.  其实你可以去上面的服务器地址看看repository是怎么构成的。

When you [update Ubuntu using the apt update command](https://itsfoss.com/update-ubuntu/), the apt package manager gets the information about the available packages (and their version info) from the repositories and stores them in local cache. You can see this in `/var/lib/apt/lists` directory.  当您使用 apt update 命令更新 Ubuntu 时，apt 包管理器会从存储库中获取有关可用包的信息（及其版本信息）并将它们存储在本地缓存中。 您可以在 /var/lib/apt/lists 目录中看到它。

Keeping this information locally speeds up the search process because you don’t have to go through the network and search the database of available packages just to check if a certain package is available or not.  将这些信息保存在本地可以加快搜索过程，因为您不必通过网络搜索可用软件包的数据库来检查某个软件包是否可用。

Now you know how repositories play an important role, let’s see why there are several repositories provided by Ubuntu.  现在您知道存储库是如何发挥重要作用的，让我们看看为什么 Ubuntu 提供了多个存储库。

## Ubuntu Repositories: Main, Universe, Multiverse, Restricted and Partner  Ubuntu 存储库：Main、Universe、Multiverse、Restricted 和 Partner

Software in Ubuntu repository are divided into five categories: main, universe, multiverse, restricted and partner.  Ubuntu 存储库中的软件分为五类：main、universe、multiverse、restricted 和 partner。

Why Ubuntu does that? Why not put all the software into one single repository? To answer this question, let’s see what are these repositories:  为什么 Ubuntu 会这样做？为什么不将所有软件放在一个存储库中？要回答这个问题，让我们看看这些存储库是什么：

### Main

When you install Ubuntu, this is the repository enabled by default. The main repository consists of only FOSS (free and open source software) that can be distributed freely without any restrictions.  安装 Ubuntu 时，这是默认启用的存储库。主存储库仅包含 FOSS（免费和开源软件），可以不受任何限制地自由分发。

Software in this repository are fully supported by the Ubuntu developers. This is what Ubuntu will provide with security updates until your system reaches end of life.  Ubuntu 开发人员完全支持此存储库中的软件。这就是 Ubuntu 将提供的安全更新，直到您的系统达到使用寿命为止。

### Universe

This repository also consists free and open source software but Ubuntu doesn’t guarantee of regular security updates to software in this category.  该存储库还包含免费和开源软件，但 Ubuntu 不保证此类软件的定期安全更新。

Software in this category are packaged and maintained by the community. The Universe repository has a vast amount of open source software and thus it enables you to have access to a huge number of software via apt package manager.  此类别中的软件由社区打包和维护。 Universe 存储库拥有大量开源软件，因此它使您能够通过 apt 包管理器访问大量软件。

### Multiverse

Multiverse contains the software that is not FOSS. Due to licensing and legal issues, Ubuntu cannot enable this repository by default and cannot provide fixes and updates.  Multiverse 包含非 FOSS 的软件。 由于许可和法律问题，Ubuntu 默认无法启用此存储库，也无法提供修复和更新。

It’s up to you to decide if you want to use the Multiverse repository and check if you have the right to use the software.  由您决定是否要使用 Multiverse 存储库并检查您是否有权使用该软件。

### Restricted  受限制的

Ubuntu tries to provide only free and open source software but that’s not always possible specially when it comes to supporting hardware.  Ubuntu 试图只提供免费和开源软件，但在支持硬件方面并不总是可行的。

The restricted repositories consist of proprietary drivers.  受限存储库由专有驱动程序组成。

### Partner  伙伴

This repository consists of proprietary software packaged by Ubuntu for their partners. Earlier, Ubuntu used to provide Skype through this repository.  该存储库由 Ubuntu 为其合作伙伴打包的专有软件组成。 早些时候，Ubuntu 曾经通过这个存储库提供 Skype。

### Third party repositories and PPA (Not provided by Ubuntu)  第三方存储库和 PPA（Ubuntu 不提供）

The above five repositories are provided by Ubuntu. You can also [add third-party repositories](https://itsfoss.com/adding-external-repositories-ubuntu/) (it’s up to you if you want to do it) to access more software or to access newer version of a software (as Ubuntu might provide old version of the same software).  以上五个存储库由 Ubuntu 提供。 您还可以添加第三方存储库（取决于您是否愿意）来访问更多软件或访问较新版本的软件（因为 Ubuntu 可能会提供相同软件的旧版本）。

For example, if you add the repository provided by [VirtualBox](https://itsfoss.com/install-virtualbox-ubuntu/), you can get the latest version of VirtualBox. It will add a new entry in your sources.list.  例如，如果您添加 VirtualBox 提供的存储库，您可以获得最新版本的 VirtualBox。 它将在您的sources.list 中添加一个新条目。

You can also install additional application using PPA (Personal Package Archive). I have written about [what is PPA and how it works](https://itsfoss.com/ppa-guide/) in detail so please read that article.  您还可以使用 PPA（个人包存档）安装其他应用程序。 我已经详细介绍了 PPA 是什么以及它是如何工作的，所以请阅读那篇文章。

> Tip: Try NOT adding anything other than Ubuntu’s repositories in your sources.list file. You should keep this file in pristine condition because if you mess it up, you won’t be able to update your system or (sometimes) even install new packages.  尽量不要在你的 sources.list 文件中添加 Ubuntu 存储库以外的任何东西。 你应该保持这个文件处于原始状态，因为如果你把它弄乱了，你将无法更新你的系统或（有时）甚至安装新的包。

## Add universe, multiverse and other repositories

As of now, you should have the main, and universe repositories enabled by default. But, if you want to enable additional repositories through the terminal, here are the commands to do that:  到目前为止，您应该默认启用主存储库和 Universe 存储库。 但是，如果您想通过终端启用其他存储库，请执行以下命令：

To enable Universe repository, use:  要启用 Universe 存储库，请使用：

```bash
sudo add-apt-repository universe
```

To enable Restricted repository, use:

```bash
sudo add-apt-repository restricted
```

To enable Multiverse repository, use this command:

```bash
sudo add-apt-repository multiverse
```

You must use sudo apt update command after adding the repository so that your system creates the local cache with package information.  添加存储库后，您必须使用 sudo apt update 命令，以便您的系统使用包信息创建本地缓存。

If you want to **remove a repository**, simply add -r like `sudo add-apt-repository -r universe`.

## Bonus Tip: How to know which repository a package belongs to?  额外提示：如何知道包属于哪个存储库？

Ubuntu has a dedicated website that provides you with information about all the packages available in the Ubuntu archive. Go to Ubuntu Packages website.  Ubuntu 有一个专门的网站，为您提供有关 Ubuntu 存档中所有可用软件包的信息。 转到 Ubuntu 软件包网站。

[Ubuntu Packages](https://packages.ubuntu.com/)

