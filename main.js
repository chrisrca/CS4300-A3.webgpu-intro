async function run() {
  const sg     = await gulls.init(),
        frag   = await gulls.import( './frag.wgsl' ),
        shader = gulls.constants.vertex + frag

  const strength = document.querySelector('#strength')
  const speed = document.querySelector('#speed')
  const scale = document.querySelector('#scale')
  const feedback = document.querySelector('#feedback')

  await Video.init()

  let strength_u = sg.uniform( strength.value )
  let speed_u = sg.uniform( speed.value )
  let scale_u = sg.uniform( scale.value )
  let feedback_u = sg.uniform( feedback.value )
  let frame_u = sg.uniform( 0 )
  const back = new Float32Array( gulls.width * gulls.height * 4 )
  const feedback_t = sg.texture( back ) 

  const render = await sg.render({
    shader,
    data:[
      sg.uniform([ sg.width, sg.height ]),
      sg.sampler(),
      frame_u,
      feedback_t,
      strength_u,
      speed_u,
      scale_u,
      feedback_u,
      sg.video( Video.element )
    ],
    onframe() { frame_u.value++ },
    copy: feedback_t
  })

  strength.oninput = ()=> strength_u.value = parseFloat( strength.value )
  speed.oninput = ()=> speed_u.value = parseFloat( speed.value )
  scale.oninput = ()=> scale_u.value = parseFloat( scale.value )
  feedback.oninput = ()=> feedback_u.value = parseFloat( feedback.value )

  sg.run( render )
}

run()