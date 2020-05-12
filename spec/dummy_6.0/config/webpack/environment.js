const { environment } = require('@rails/webpacker')

//// Begin driver code ////
const { config } = require('@rails/webpacker')
const { sync } = require('glob')
const { basename, dirname, join, relative, resolve } = require('path')
const extname = require('path-complete-extname')

const getExtensionsGlob = () => {
  const { extensions } = config
  return extensions.length === 1 ? `**/*${extensions[0]}` : `**/*{${extensions.join(',')}}`
}

const addToEntryObject = (sourcePath) => {
  const glob = getExtensionsGlob()
  const rootPath = join(sourcePath, config.source_entry_path)
  const paths = sync(join(rootPath, glob))
  paths.forEach((path) => {
    const namespace = relative(join(rootPath), dirname(path))
    const name = join(namespace, basename(path, extname(path)))
    environment.entry.set(name, resolve(path))
  })
}

sync('drivers/*').forEach((driverPath) => {
  addToEntryObject(join(driverPath, config.source_path));
})
//// End driver code ////

module.exports = environment
