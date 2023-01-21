# Jekyll in a Docker Container: Veeva Vault Help Edition

This is a fork of [Bret Fisher's](https://bretfisher.com/) excellent [Docker images for Jekyll](https://github.com/BretFisher/jekyll-serve). I'd been using `bretfisher/jekyll-serve` for the [Veeva Vault Help](https://veevavault.help/) project at my day job, and recently his update to Ruby 3 looks to have caused our development builds to become surprisingly slow [^1] on Intel Macs to the point where what once took approximately three minutes could build for hours and never complete. 

Bret is a good human being and he did a great job helping me figure out what was happening and to nail down the software versions we want to pin to. I forked his repository, merged in the branch that worked for our project, took a few things out that we didn't need (I'll get to that) and somehow fumbled my way into this intial version with a working set of Docker images. I'm not entirely sure if they're different, but they're there, and they work.

`ghcr.io/tostanoski/vvh-jekyll`

`ghcr.io/tostanoski/vvh-jekyll-serve`

You _probably_ don't want to use these images for your project. If you do and you find that they work, you should do what I did above and fork the project. Juggling images when things change is not fun.

Here's what I changed from the original:

* When I change the image, it doesn't publish to Docker Hub. I might do this eventually, as it seems to be proper form. GHCR seems to be working fine, so once I have proper access through my employer I'll look into it.
* Changed all the image names to protect the guilty.
* Updated the copyright on the MIT license, dropped the Funding file (nothing I have done here is worth your money; give it to Bret), and updated this README. 
* More significantly, I yanked out all the `arm/v7` references. We're a Mac shop, and while IT has started deploying M1 MacBook Pros, the bulk of our team still has Intel Macs. So, our image must include `arm64` and `amd64`, and once every writer is transitioned to the new platform, `amd64` will likely go away. Yeah, roll your own. Don't do what I did and then end up in a spot because of something I did :smile:

As I learn more about Docker images, GitHub Actions, and how all of the moving parts for Jekyll work together I'm going to try to optimize things further. One of my employer's core values is Speed. The more I can get Jekyll and Docker out of the way of the writers, the faster they can commit their article updates. They're happy, the powers that be are happy, and I'm happy, mostly because everyone else is happy. 

What follows is all the technical goodness that Bret wrote. It's kept here for posterity. I don't recommend using instructions to set things up, as, again, you probably don't want to use these images. But, there's here for now, possibly to help with future development. I must find out if there's a best practice for this.

[^1]: It's a really, really big project. Thousand pages or thereabouts. When we do production builds a number of websites are made out of subsets of these pages. The tech writers have the ability to make local production builds for testing purposes, but Jekyll's development server is usually more convenient for their purposes. This cranky old man does indeed have a heart, and instead of making everyone do it like me, I do my best to make things easy for them.

```

[![GitHub Super-Linter](https://github.com/bretfisher/jekyll-serve/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)
[![Docker Build](https://github.com/BretFisher/jekyll-serve/actions/workflows/call-docker-build.yaml/badge.svg)](https://github.com/BretFisher/jekyll-serve/actions/workflows/call-docker-build.yaml)

> But this has been done. Why not `docker run jekyll/jekyll`?

- I wanted two images, one for easy CLI (`bretfisher/jekyll`) and one for
easy local server for dev with sane defaults (`bretfisher/jekyll-serve`), which I use 90% of the time
- So you can start any Jekyll server with `docker-compose up`
- I wanted to dev on a local Jekyll site without having Jekyll installed on my host OS
- I wanted it to be as easy as possible to start
- I wanted current `amd64` and `arm64` images using official Ruby and Jekyll latest

> So, this does that.

Note [I have courses on Docker (including a Lecture on Jekyll in Docker)](https://www.bretfisher.com/courses).

:bangbang: :bangbang: :bangbang:

:warning: WARNING: :warning: This isn't meant to be a production image that you run a web server with. I don't do that with the Jekyll
CLI that comes with this image. Jekyll CLI generates
a static site that you can run with GitHub Pages, Netlify, or your own NGINX setup.  Furthermore, I don't version
anything so these images will not run guaranteed versions of Ruby, Jekyll, etc. (which, if you're running a server,
should pin all versions usually.)

## Docker Images

| Image | Purpose | Example |
| ----- | ------- | ------- |
| [bretfisher/jekyll](https://hub.docker.com/r/bretfisher/jekyll/) | Runs Jekyll by default with no options, good for general CLI commands | `docker run -v $(pwd):/site bretfisher/jekyll new .` |
| [bretfisher/jekyll-serve](https://hub.docker.com/r/bretfisher/jekyll-serve/) | Runs Jekyll serve with sane defaults, good for local Jekyll site dev | `docker run -p 4000:4000 -v $(pwd):/site bretfisher/jekyll-serve` |

## Getting Started

Creating a site:

```shell
cd to empty directory
docker run -v $(pwd):/site bretfisher/jekyll new .
```

Start a local server with sane defaults listening on port 4000:

```shell
cd dir/of/your/jekyll/site
docker run -p 4000:4000 -v $(pwd):/site bretfisher/jekyll-serve
```

That's it!

Details: it will mount your current path into the containers `/site`, `bundle install` before running
`jekyll serve` to , serve it at `http://<docker-host>:4000`.

To make this even easier, copy `docker-compose.yml`
[from this repository](https://github.com/BretFisher/jekyll-serve/blob/master/docker-compose.yml)
to your jekyll site root. Then you'll only need to:

```shell
cd dir/of/your/jekyll/site
docker-compose up
```

## Known issues

1. `arm/v7` version (aka `armhf`) doesn't exist in this repository.
    - Yes, `arm/v7` has become too difficult to support.
2. `alpine` version doesn't exist in this repository.
    - Yes, not all Jekyll dependencies are built with `musl` support, so `glibc`-based images are now the only option (Debian).
3. RESOLVED as of Jekyll 4.3
    ~~`webrick` errors during startup.~~
    - ~~As of April 2021, Ruby 3.0 is out, and Jekyll is still on 4.2 (released 12/2020). Jekyll 4.2 doesn't have `webrick` listed as a dependency, so we'll have to manually add it to Gemfile for now if you want to use Ruby 3.0.~~
    ~~Ruby 3.0 removed this bundled gems so you'll need to add them manually if you use them: `sdbm`, `webrick`, `net-telnet`, `xmlrpc`. Hopefully Jekyll 4.3 will have `webrick` listed as a Jekyll dependency (it is fixed in Jekyll master branch) so manually updating Gemfiles won't be needed.~~

## Q&A

**Q. What if I want to run other jekyll commands?**

just add the jekyll options to the end of the `bretfisher/jekyll`:

```shell
docker run -v $(pwd):/site bretfisher/jekyll doctor
```
```
