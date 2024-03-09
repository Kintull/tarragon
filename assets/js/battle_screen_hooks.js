import * as THREE from 'three';
import {CSS2DRenderer, CSS2DObject} from 'three/examples/jsm/renderers/CSS2DRenderer.js';
import {TextGeometry} from 'three/examples/jsm/geometries/TextGeometry.js';
import {FontLoader} from 'three/examples/jsm/loaders/FontLoader.js';
import {OrbitControls} from 'three/examples/jsm/controls/OrbitControls.js';

let camera, scene, renderer, labelRenderer;

function init() {
    const scene_width = document.getElementById('threejsContainer').offsetWidth;
    const scene_height = document.getElementById('threejsContainer').offsetHeight;
    const marks_numbers = 4;

    renderer = new THREE.WebGLRenderer({antialias: true});
    renderer.setSize(scene_width, scene_height);

    labelRenderer = new CSS2DRenderer();
    labelRenderer.setSize(scene_width, scene_height);
    labelRenderer.domElement.style.position = 'absolute';
    labelRenderer.domElement.style.top = '0px';

    document.getElementById('threejsContainer').appendChild(labelRenderer.domElement);
    document.getElementById('threejsContainer').appendChild(renderer.domElement);

    scene = new THREE.Scene();

    // Setting up the orthographic camera
    const aspectRatio = scene_width / scene_height;
    const frustumSize = scene_height;
    camera = new THREE.OrthographicCamera(
        (frustumSize * aspectRatio) / -2,
        (frustumSize * aspectRatio) / 2,
        frustumSize / 2,
        frustumSize / -2,
        1,
        2000
    );

    // Adjusting the camera making 0,0 at the bottom left, x - horizonal, y - vertical
    camera.position.set(scene_width / 2, scene_height / 2, 1);
    scene.add(camera);


    // Now, let's create a range sector
    const circle_x = 10;
    const circle_y = 10;
    const circleRadius = scene_height - circle_y;
    const sector_start = Math.acos((scene_width - circle_x) / circleRadius)
    const sector_len = Math.PI / 2 - sector_start - Math.PI / 16
    const geometry2 = new THREE.CircleGeometry(circleRadius, 32, sector_start, sector_len); // Adjust the radius and segments as needed
    const material2 = new THREE.MeshBasicMaterial({color: 0x0095ff, transparent: true, opacity: 0.2});
    const circle = new THREE.Mesh(geometry2, material2);
    circle.position.set(circle_x, circle_y, 0);
    scene.add(circle);

    // circle border left
    const xLeft = circleRadius * Math.cos(sector_start + sector_len) + circle_x;
    const yLeft = circleRadius * Math.sin(sector_start + sector_len) + circle_y;
    const materialLeft = new THREE.LineBasicMaterial({color: 0x000000});
    const pointsLeft = [];
    pointsLeft.push(new THREE.Vector3(circle.position.x, circle.position.y));
    pointsLeft.push(new THREE.Vector3(xLeft, yLeft, 0));
    const geometryLeft = new THREE.BufferGeometry().setFromPoints(pointsLeft);
    const lineLeft = new THREE.Line(geometryLeft, materialLeft);
    scene.add(lineLeft);

    // circle border right
    const xRight = circleRadius * Math.cos(sector_start) + circle_x;
    const yRight = circleRadius * Math.sin(sector_start) + circle_y;
    const materialRight = new THREE.LineBasicMaterial({color: 0x000000});
    const pointsRight = [];
    pointsRight.push(new THREE.Vector3(circle.position.x, circle.position.y));
    pointsRight.push(new THREE.Vector3(xRight, yRight, 0));
    const geometryRight = new THREE.BufferGeometry().setFromPoints(pointsRight);
    const lineRight = new THREE.Line(geometryRight, materialRight);
    scene.add(lineRight);

    // mark 0
    const sphereGeometry0 = new THREE.CircleGeometry(3, 32);
    const sphereMaterial0 = new THREE.MeshBasicMaterial({color: 0x000000});
    const mark0 = new THREE.Mesh(sphereGeometry0, sphereMaterial0);
    mark0.position.set(circle.position.x, circle.position.y, 0);
    scene.add(mark0);

    // the rest of the labels and lines
    for (let i = 1; i <= marks_numbers; i++) {
        const distance = circleRadius / marks_numbers * i;
        let x = distance * Math.cos(sector_start + sector_len / 2) + circle_x;
        let y = distance * Math.sin(sector_start + sector_len / 2) + circle_y;
        const sphereGeometry = new THREE.CircleGeometry(3, 32);
        const sphereMaterial = new THREE.MeshBasicMaterial({color: 0x000000});
        const mark = new THREE.Mesh(sphereGeometry, sphereMaterial);
        mark.position.set(x, y, 0);
        scene.add(mark);

        const labeDiv = document.createElement('div');
        labeDiv.className = 'label';
        labeDiv.textContent = i;
        const label = new CSS2DObject(labeDiv);
        label.position.set(mark.position.x, mark.position.y);
        label.center.set(0, -1);
        mark0.add(label);

        const g = new THREE.BufferGeometry().setFromPoints(
            new THREE.Path().absarc(circle.position.x, circle.position.y, distance, sector_start, sector_start + sector_len).getSpacedPoints(32)
        );
        const m = new THREE.LineBasicMaterial({color: "black"});
        const l = new THREE.Line(g, m);
        scene.add(l);
    }
}

function animate() {
    requestAnimationFrame(animate);
    // uncomment to make transparent
    renderer.setClearColor(0x000000, 0);
    labelRenderer.render(scene, camera);
    renderer.render(scene, camera);

}


export function createBattleScreenHooks() {
    return {
        BattleScreenHooks: {
            mounted() {
                console.log("BattleScreenHooks mount");
                init();
                animate();
                console.log("BattleScreenHooks mount after animate");
            },
            updated() {
                console.log("BattleScreenHooks updated");
                init();
                animate();
                console.log("BattleScreenHooks updated after animate");
            }
        }
    }
}

